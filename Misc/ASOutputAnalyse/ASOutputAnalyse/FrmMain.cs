/*

MIT License

Copyright (c) 2026 Alexander Hefner
 
See LICENCE.TXT for details
 
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.IO;
using System.Xml;
using System.Diagnostics;

namespace ASOutputAnalyse
{
    public partial class FrmMain : Form
    {

        // output path
        string _OutputPath = "";
        string _InputPath = "";
        string _WarnInputPath = "";
        bool _WarnInAsPostBuild = false;
        bool _AutoClose = false;
        bool _AutoRun = false;
        int _ExitCode = 0;
        bool _ASPostBuildEvent = false;

        // load settings
        public FrmMain(string[] args)
        {
            InitializeComponent();

            // prepare load settings from file
            GetSettings settingsObj = new GetSettings();
            Dictionary<string, string> dictSettings = settingsObj.LoadFromFile();

            // load settings independent from GUI or COMMANNDLINE mode
            if (dictSettings.Count > 0)
            {
                string value = "";
                if (dictSettings.TryGetValue("ashelppath", out value))
                    lblHelpPath.Text = value;
            }

            // start arguments found ==> COMMAND LINE MODE
            if (args.Length > 0)
            {
                this.Text = this.Text + " - CMD MODE, MOST SETTINGS FROM SET-FILE ARE IGNORED !!!!";

                foreach (string argument in args)
                {
                    if (argument.StartsWith("-"))
                    {
                        // remove -
                        string arg = argument.Remove(0, 1);
                        arg = arg.ToLower();

                        // check if argument has property
                        string[] cmdv = arg.Split('=');
                        if (cmdv.Length == 1)
                        {
                            switch (cmdv[0].ToLower())
                            {
                                case "last":
                                    ChkLastBuildOnly.Checked = true;
                                    break;
                                case "skipmsg":
                                    chkSkipMessages.Checked = true;
                                    break;
                                case "summary":
                                    ChkSaveSummaryOnly.Checked = true;
                                    chkSaveResult.Checked = true;
                                    break;
                                case "result":
                                    chkSaveResult.Checked = true;
                                    break;
                                case "autoclose":
                                    _AutoClose = true;
                                    break;
                                case "aspostbuild":
                                    _ASPostBuildEvent = true;
                                    _AutoClose = true;
                                    break;
                            }
                        }
                        if (cmdv.Length == 2)
                        {
                            // only commands with -CMD=ARGUMENT are valid, everything else is ignored!
                            switch (cmdv[0].ToLower())
                            {
                                case "in":
                                    // this one should be a path + filename, so set / overwrite the default values from settings file
                                    openFileDialog1.InitialDirectory = Path.GetDirectoryName(cmdv[1]);
                                    openFileDialog1.FileName = openFileDialog1.InitialDirectory + "\\" +  Path.GetFileName(cmdv[1]);
                                    _InputPath = cmdv[1];
                                    // start automatically!
                                    _AutoRun = true;
                                    break;
                                case "out":
                                    // this one should be a path + filename, so set / overwrite the default values from settings file
                                    _OutputPath = cmdv[1];
                                    break;
                                // 2022-10-19 - special functionality "warn if something was found inside the log"
                                case "userwarnings":
                                    _WarnInputPath = cmdv[1];
                                    _WarnInAsPostBuild = true;
                                    // setup other needed parameters
                                    //_ASPostBuildEvent = true;
                                    //ChkLastBuildOnly.Checked = true;
                                    break;
                            }
                        }
                    }
                }
            }
            // no start parameters ==> GUI MODE
            else
            {
                // check for settings in file and use them
                if (dictSettings.Count > 0)
                {
                    string value = "";
                    if (dictSettings.TryGetValue("logfilepreset", out value))
                    {
                        openFileDialog1.InitialDirectory = Path.GetDirectoryName(value);
                        openFileDialog1.FileName = Path.GetFileName(value);
                    }
                    if (dictSettings.TryGetValue("ashelppath", out value))
                        lblHelpPath.Text = value;
                    if (dictSettings.TryGetValue("saveresult", out value))
                    {
                        if (value.ToLower() == "true")
                            chkSaveResult.Checked = true;
                    }
                    if (dictSettings.TryGetValue("savesummaryonly", out value))
                    {
                        if (value.ToLower() == "true")
                            ChkSaveSummaryOnly.Checked = true;
                    }
                    if (dictSettings.TryGetValue("skiplogfilemessages", out value))
                    {
                        if (value.ToLower() == "true")
                            chkSkipMessages.Checked = true;
                    }
                    if (dictSettings.TryGetValue("showlastonly", out value))
                    {
                        if (value.ToLower() == "true")
                            ChkLastBuildOnly.Checked = true;
                    }
                }
            }

            if (_OutputPath == String.Empty)
            {
                string dir = Path.GetDirectoryName(openFileDialog1.FileName);
                string file = Path.GetFileName(openFileDialog1.FileName);
                string ext = "_" + DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss") + "_analyzed.txt";
                _OutputPath = dir + "\\" + file + ext;
            }

            if (_AutoRun == true)
                Run();

        }

        // start analyze
        private void Run()
        {
            // load and parse file
            if (File.Exists(_InputPath))
            {

                List<string> ListWarnIfContains = null;

                if (_WarnInAsPostBuild == true)
                {
                    // warning mode is active - read warning list!
                    if (File.Exists(_WarnInputPath))
                    {
                        ListWarnIfContains = new List<string>();
                        string[] warnContent = File.ReadAllLines(_WarnInputPath);
                        foreach (string s in warnContent)
                        {
                            string w = s.Replace("\t", "");
                            if (w != "")
                                ListWarnIfContains.Add(w);
                        }
                    }
                    else
                    { 
                        // TODO - which exit code? Break or keep running?
                    }
                }
                
                List<OutputBuild> OutputBuildsList = ReadASLogFile(_InputPath, ChkLastBuildOnly.Checked, ListWarnIfContains);

                // TODO - if warn reasults, where to output?


                // show in treeview
                List<string> txtFileList = UpdateTreeView(OutputBuildsList, ChkSaveSummaryOnly.Checked);

                if (txtFileList.Count == 0)
                {
                    // no complete build run found!
                    MessageBox.Show("Sorry, no complete build run found!\nMaybe not a AS output log, or logsize too small?", "Nothing to display :-(");
                    _ExitCode = -1;
                }
                else
                {
                    // save output
                    if (chkSaveResult.Checked)
                    {
                        SaveOutputToFile(_OutputPath, txtFileList);
                    }

                    // get and display user configured warnings
                    List<string> ListUserWarnings = CollectUserWarnings(OutputBuildsList);
                    if (ListUserWarnings.Count > 0)
                    {

                        //MessageBox.Show("Some user defined patterns were found inside the log file!\r\n\r\nPlease CHECK them CAREFULLY because even if they do not lead to a compile error, they could lead to malfunction!", "User specified error!", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                        FrmUserWarnings frm = new FrmUserWarnings(ListUserWarnings);
                        frm.ShowDialog();
                    }
                }
            }
            else
            {
                MessageBox.Show("Sorry, input file not found!\n" + _InputPath, "Nothing to analyze :-(");
                _ExitCode = -3;
            }
        }

        private List<string> CollectUserWarnings(List<OutputBuild> OutputBuildsList)
        {
            List<string> ListUserWarnings = new List<string>();
            try
            {
                foreach (OutputBuild buildObj in OutputBuildsList)
                {
                    Dictionary<string, OutputObject> dict = buildObj.GetDict();
                    foreach (KeyValuePair<string, OutputObject> kvp in dict)
                    {
                        foreach (OutputEntry entry in kvp.Value.GetList())
                        {
                            if (entry.ContainsUserWarningElement == true)
                            {
                                // this entry contains at least one user warning specified string
                                string userWarning = entry.FirstUserWarningString + "|" + entry.EntryNumber + "|" + entry.Text + "|" + entry.Type + "|" + entry.ErrorNumber + "|" + entry.OriginLineNumber;
                                ListUserWarnings.Add(userWarning);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
            }
            return ListUserWarnings;
        }

        // load, parse the log file
        private void btnOpenLogFile_Click(object sender, EventArgs e)
        {
            // clean web view
            webBrowser1.Navigate("about:blank");

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                _InputPath = openFileDialog1.FileName;
                Run();
            }
        }

        // display data in treeview and web viewer,  generate output file
        private List<string> UpdateTreeView(List<OutputBuild> OutputBuildsList, bool summaryOnly)
        {

            List<string> textFileComplete = new List<string>();

            List<string> textFileList = new List<string>();
            textFileList.Add("* Details: ");

            List<string> textFileSummary = new List<string>();
            textFileSummary.Add("* Summary: ");

            GetInfoFromAsHelp getHelpInfo = new GetInfoFromAsHelp(lblHelpPath.Text);

            Cursor currentCursor = this.Cursor;
            this.Cursor = Cursors.WaitCursor;

            // now display as tree view
            treeView1.Nodes.Clear();
            treeView1.BeginUpdate();

            try
            {
                foreach (OutputBuild buildObj in OutputBuildsList)
                {
                    Dictionary<string, OutputObject> dict = buildObj.GetDict();
                    TreeNode rootNode = treeView1.Nodes.Add(buildObj.BuildDateTime + " " + buildObj.BuildName + " " + buildObj.BuildResult);
                    textFileComplete.Add(rootNode.Text);

                    foreach (KeyValuePair<string, OutputObject> kvp in dict)
                    {
                        string htmlInfo = "";
                        string errorGroup = "";
                        if (getHelpInfo.IsHelpAvailable() == true)
                        {
                            htmlInfo = getHelpInfo.GetErrorNumberHtmlPath(kvp.Key);
                            errorGroup = getHelpInfo.GetErrorGroupInformation(kvp.Key);
                        }

                        string nodeName = "{ " + kvp.Value.Count.ToString() + " }     " + kvp.Value.Type + " : " + kvp.Key;
                        if (errorGroup != string.Empty)
                        {
                            nodeName += "     (" + errorGroup + ")";
                        }

                        TreeNode objNode = rootNode.Nodes.Add(nodeName);
                        if (htmlInfo != string.Empty)
                        {
                            objNode.Tag = htmlInfo;
                        }

                        textFileList.Add("| " + objNode.Text);
                        textFileSummary.Add("| " + objNode.Text);

                        foreach (OutputEntry entry in kvp.Value.GetList())
                        {

                            if (entry.ErrorNumber != "-1" || chkSkipMessages.Checked == false)
                            {

                                TreeNode entryNode = objNode.Nodes.Add(entry.Text);
                                textFileList.Add("|---> " + entry.Text);
                                if (entry.Path != "")
                                {
                                    entryNode.Nodes.Add(entry.Path);
                                    textFileList.Add("|------> " + entry.Path);
                                }
                                if (entry.Position != "")
                                {
                                    entryNode.Nodes.Add(entry.Position);
                                    textFileList.Add("|------> " + entry.Position);
                                }
                                entryNode.Nodes.Add(entry.DateTime);
                                textFileList.Add("|------> " + entry.DateTime);
                                entryNode.Nodes.Add("Build # " + entry.EntryNumber);
                                textFileList.Add("|------> Build # " + entry.EntryNumber);
                                entryNode.Nodes.Add("log file line: " + entry.OriginLineNumber);
                                textFileList.Add("|------> log file line: " + entry.EntryNumber);
                            }
                        }
                    }
                    // add summary
                    textFileComplete.AddRange(textFileSummary);
                    if (!summaryOnly)
                    {
                        // add details
                        textFileComplete.AddRange(textFileList);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
            
            treeView1.EndUpdate();

            this.Cursor = currentCursor;

            return textFileComplete;

        }

        //load AS help file into web view
        private void treeView1_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (e.Node.Tag != null)
            {
                string path = e.Node.Tag.ToString();
                string url = "file://" + path.Replace("\\", "/");
                webBrowser1.Navigate(url);
            }
            else
            {
                // clean web view
                webBrowser1.Navigate("about:blank");
            }
        }

        // read the log file and build the data structures 
        private List<OutputBuild> ReadASLogFile(string fileName, bool showLastOnly, List<string>ListWarnIfContains)
        {

            OutputBuild BuildObject = new OutputBuild();
            List<OutputBuild> OutputBuildsList = new List<OutputBuild>();

            try
            {
                string[] output = File.ReadAllLines(fileName);

                int iBuilderEventCount = 0;
                int iOriginLineNumber = 0;
                bool bEndOfBuildReached = false;

                foreach (string line in output)
                {
                    iOriginLineNumber++;
                    if (line != string.Empty)
                    {
                        // divide date time and reminder
                        string[] tmp = line.Split(new char[] { ' ' }, 3);

                        if (tmp.Length > 2 && tmp[2] != "") // some entries are only date and time, we're not interested in this lines
                        {
                            string entryDateTime = tmp[0] + " " + tmp[1];
                            string entryReminder = tmp[2];

                            // find first / next "build start event"
                            if (entryReminder.Contains("------"))
                            {
                                // next build start entry found, we need a new list object
                                if (BuildObject.NrOfEntries() > 0)
                                {
                                    // add last
                                    OutputBuildsList.Add(BuildObject);

                                    // generate new 
                                    BuildObject = new OutputBuild();
                                }

                                // new build start event found
                                bEndOfBuildReached = false;
                                iBuilderEventCount++;
                                OutputEntry entry = new OutputEntry(ListWarnIfContains);
                                entry.OriginLineNumber = iOriginLineNumber.ToString();
                                entry.ParseLine(entryDateTime, entryReminder);

                                // add build information
                                BuildObject.BuildDateTime = entry.DateTime;
                                BuildObject.BuildName = entry.Text;

                                BuildObject.Add(entry);
                            }
                            else
                            {
                                if (iBuilderEventCount > 0)
                                {
                                    // somewehere inside a build event
                                    // check entry, sort it, a.s.o...
                                    OutputEntry entry = new OutputEntry(ListWarnIfContains);
                                    entry.OriginLineNumber = iOriginLineNumber.ToString();
                                    entry.ParseLine(entryDateTime, entryReminder);
                                    BuildObject.Add(entry);
                                    if (entry.Text.Contains("Build:") || entry.Text.Contains("Kompilieren:"))
                                    {
                                        // end of build event found
                                        bEndOfBuildReached = true;
                                        BuildObject.BuildResult = " ( " + entry.Text + " ) ";
                                    }
                                }
                                // else ... the log begins with old entries, ignore them until we found the first start-of-build
                            }
                        }
                    }
                }
                if (BuildObject.NrOfEntries() > 0 && (bEndOfBuildReached == true || _ASPostBuildEvent == true))
                {
                    // only add last list if it was a complete build .....
                    // .... or if we are inVERY VERY SPECIAL MODE - Usage with AS post build event ... means that AS has not finished yet the log file by entry "Build:"!!
                    OutputBuildsList.Add(BuildObject);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }

            if (showLastOnly)
            {
                if (OutputBuildsList.Count > 0)
                {
                    OutputBuildsList.RemoveRange(0, OutputBuildsList.Count - 1);
                }
            }
            return OutputBuildsList;
        }

        // save the result to output file
        private void SaveOutputToFile(string fileName, List<string> txtFileList)
        {
            try
            {
                string[] fileContent = txtFileList.ToArray();
                if (File.Exists(fileName)) File.Delete(fileName);
                File.WriteAllLines(fileName, fileContent);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
                _ExitCode = -2;
            }
        }

        // open the loaded log file in external editor
        private void linkOpenLogFileInEditor_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            if (File.Exists(openFileDialog1.FileName))
            {
                try
                {
                    Process.Start(openFileDialog1.FileName);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.ToString());
                }
            }
            else
            {
                MessageBox.Show("no file loaded or file not found!");
            }
        }

        // open the settings file in external editor
        private void linkOpenSettingsInEditor_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            GetSettings settingsObj = new GetSettings();
            if (File.Exists(settingsObj.SettingsFile))
            {
                try
                {
                    Process.Start("notepad.exe", settingsObj.SettingsFile);
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.ToString());
                }
            }
            else
            {
                MessageBox.Show("settings file not found!");
            }
        }

        // end up here if we're in autoclose mode
        private void Form1_Shown(object sender, EventArgs e)
        {
            // End program here if configured!!
            if (_AutoClose)
            {
                Environment.ExitCode = _ExitCode;
                Application.Exit();
            }
        }

    }

    // directory with error information subdirs: C:\BrAutomation\AS47\Help-de\Data\diagnostics_support\errors
    // inside there is a XML file "errors.xml", which contains links to all error pages 
    public class GetInfoFromAsHelp
    {

        private XmlDocument xmldocAsHelpLinks;
        private Dictionary<string, string[]> dictHelpReadBuffer = new Dictionary<string, string[]>();
        private string basePath;
        private bool isHelpAvailable = false;
        private string exceptString;
        public string ExceptionInfo { get { return exceptString; } }

        public GetInfoFromAsHelp(string basePathToErrors)
        {
            basePath = basePathToErrors;
            xmldocAsHelpLinks = new XmlDocument();
            if (File.Exists(basePath + "\\errors.xml"))
            {
                xmldocAsHelpLinks.Load(basePath + "\\errors.xml");
                isHelpAvailable = true;
            }
        }

        public bool IsHelpAvailable()
        {
            return isHelpAvailable;
        }

        // get the AS path for the error number specific help file
        public string GetErrorNumberHtmlPath(string errornumber)
        {
            string result = "";

            if (errornumber != string.Empty && isHelpAvailable == true)
            {
                try
                {
                    XmlNodeList xnList = xmldocAsHelpLinks.SelectNodes("/Help/Section/Section/Page[@Text='" + errornumber + "']");
                    if (xnList != null && xnList.Count > 0)
                    {
                        XmlNode xNode = xnList[0];  // there should be only one node!!!
                        string detailDocPath = xNode.Attributes["File"].Value;
                        string errorParent = xNode.ParentNode.Attributes["Text"].Value;
                        // only read each path once ... could be helpful when using only one instance of this class for more then one parsing...
                        if (dictHelpReadBuffer.ContainsKey(errornumber))
                        {
                            result = dictHelpReadBuffer[errornumber][0];
                        }
                        else
                        {
                            // we have to read the file
                            string fn = basePath + "\\" + detailDocPath;
                            dictHelpReadBuffer.Add(errornumber, new string[] { fn, errorParent});
                            result = fn;
                        }

                    }
                }
                catch (Exception ex)
                {
                    exceptString = ex.ToString();
                }
            }

            return result;
        }
        
        // get the builder grup who reports the error
        public string GetErrorGroupInformation(string errornumber)
        {
            string result = "";

            if (dictHelpReadBuffer.ContainsKey(errornumber))
            {
                result = dictHelpReadBuffer[errornumber][1];
            }
            else
            {
                // was not read before
                if (GetErrorNumberHtmlPath(errornumber) != string.Empty)
                {
                    result = GetErrorGroupInformation(errornumber);
                }
            }

            return result;
        }

    }

    // class for one entry in log file
    public class OutputEntry : IEquatable<OutputEntry>
    {
        public string DateTime { get; set; }
        public string Type { get; set; }
        public string ErrorNumber { get; set; }
        public string Text { get; set; }
        public string Path { get; set; }
        public string Position { get; set; }
        public string EntryNumber { get; set; }
        public string OriginLineNumber { get; set; }

        private string exceptString;
        public string ExceptionInfo { get { return exceptString; } }

        // needed for "warn if contains" functionality
        private List<string> ListOfContains;
        private bool foundContainsString = false;
        private string foundUserWarningString = "";
        public bool ContainsUserWarningElement { get { return foundContainsString; } }
        public string FirstUserWarningString { get { return foundUserWarningString; }  }


        public OutputEntry()
        {
            this.Initialize();
            ListOfContains = null;
        }

        public OutputEntry(List<string> ListOfWarnElements)
        {
            this.Initialize();
            ListOfContains = ListOfWarnElements;
        }

        public bool Equals(OutputEntry other)
        {
            if (other == null) return false;
            return (this.ErrorNumber.Equals(other.ErrorNumber));
        }

        public override string ToString()
        {
            return EntryNumber + " " + DateTime + " " + ErrorNumber + " " + Type + " " + Text + " " + Path + " " + Position;
        }

        public void Initialize()
        {
            DateTime = "";
            ErrorNumber = "NOT SET";  // means uninitialized
            Type = "";
            Text = "";
            Path = "";
            Position = "";
        }

        public void ParseLine(string datetime, string reminder)
        {

            try
            {
                if (ListOfContains != null && ListOfContains.Count > 0)
                {
                    foundContainsString = ListOfContains.Any(s => reminder.IndexOf(s, StringComparison.OrdinalIgnoreCase) >= 0);
                    if (foundContainsString)
                    {
                        // which one? Only the first ...
                        foreach (string s in ListOfContains)
                        {
                            if (reminder.IndexOf(s, StringComparison.OrdinalIgnoreCase) >= 0)
                            {
                                foundUserWarningString = s;
                                break;
                            }
                        }
                    }
                }
                
                this.DateTime = datetime;

                string[] entryData = reminder.Split(new string[] { " : " }, StringSplitOptions.RemoveEmptyEntries);

                // first check for some keywords to set the type
                if (entryData.Length > 0)
                {
                    if (reminder.Contains("Error ") || reminder.Contains("Fehler "))
                    {
                        this.Type = "Error";
                        this.ErrorNumber = "NO ERROR NUMBER";  // 
                    }
                    else
                    {
                        if (reminder.Contains("Warning ") || reminder.Contains("Warnung "))
                        {
                            this.Type = "Warning";
                            this.ErrorNumber = "NO WARNING NUMBER";  // 
                        }
                        else
                        {
                            this.Type = "Message";
                            this.ErrorNumber = "-1";  // 
                        }
                    }
                }

                // split into path and position information (if available)
                string[] pAndP = GetPathAndPosition(entryData[0]);
                string[] details;

                switch (entryData.Length)
                {
                    case 0:
                        // do nothing, should not happen
                        break;
                    case 1:
                        // if only 1 element, normally it's a info ... but some entries also start with error or warning
                        if (this.Type == "Message")
                        {
                            this.Text = entryData[0];
                        }
                        else
                        {
                            // possibly starts with error or warning
                            details = entryData[0].Split(new char[] { ' ' }, 3);
                            if (details.Length > 2 && details[1].Contains(":"))
                            {
                                // it is like mentioned
                                this.ErrorNumber = details[1].Replace(":", "");
                                this.Text = details[2];
                            }
                            else
                            {
                                // don't know what it is, handle like message
                                this.Text = entryData[0];
                            }
                        }
                        break;
                    case 2:
                        // first should be a path, second the type, number and text
                        this.Path = pAndP[0];
                        this.Position = pAndP[1];
                        details = entryData[1].Split(new char[] { ' ' }, 3);
                        int errornumber = 0;
                        if (Int32.TryParse(details[1].Replace(":", ""), out errornumber) == true)
                        {
                            // this is a warning or a error
                            this.ErrorNumber = details[1].Replace(":", "");
                            this.Text = details[2];
                        }
                        else
                        {
                            // handle it like a information
                            for (int i = 1; i < details.Length; i++)
                                this.Text = this.Text + details[i];
                        }
                        break;
                    case 3:
                        // C/C++, rules are not the same then IEC compiler!?
                        this.Text = entryData[2];
                        this.Path = pAndP[0];
                        this.Position = pAndP[1];
                        break;
                    default:
                        // should not happen? copy whole entry, mark as "unparsable"
                        this.Type = "CannotParse";
                        this.Text = reminder;
                        break;

                }
            }
            catch (Exception ex)
            {
                exceptString = ex.ToString();
            }
        }

        private string[] GetPathAndPosition(string pathAndPosition)
        {
            string[] result = { pathAndPosition, "" };
            bool patternEn = pathAndPosition.Contains("(Ln:");
            bool patternDe = pathAndPosition.Contains("(Ze:");
            if (patternEn || patternDe)
            {
                int startIndex = 0;
                if (patternEn) startIndex = pathAndPosition.IndexOf("(Ln:");
                if (patternDe) startIndex = pathAndPosition.IndexOf("(Ze:");
                int endIndex = pathAndPosition.IndexOf(")", startIndex);
                result[1] = pathAndPosition.Substring(startIndex + 1, endIndex - startIndex - 1);
                result[0] = pathAndPosition.Substring(0, startIndex);
            }
            return result;
        }
    }

    // class to assign entries to a errornumber group
    public class OutputObject
    { 
        public string Number { get; set; }
        public string Type { get; set; }
        public int Count { get { return _Count; } }

        private List<OutputEntry> _ListOfEntries = new List<OutputEntry>();
        private int _Count = 0;

        
        public void Add(OutputEntry entry)
        {
            _ListOfEntries.Add(entry);
            _Count++;
        }

        public List<OutputEntry> GetList()
        {
            return _ListOfEntries;
        }

    }



    // class for all groups within one build
    public class OutputBuild
    { 
        public string BuildName { get; set; }
        public string BuildDateTime { get; set; }
        public string BuildResult { get; set; }

        private Dictionary<string, OutputObject> _DictOfObjects = new Dictionary<string, OutputObject>();
        private int iEntryNumber;

        public OutputBuild()
        {
            iEntryNumber = 0;
        }

        public void Add(OutputEntry entry)
        {
            iEntryNumber++;
            entry.EntryNumber = iEntryNumber.ToString();
            if (_DictOfObjects.ContainsKey(entry.ErrorNumber))
            {
                OutputObject obj = _DictOfObjects[entry.ErrorNumber];
                obj.Add(entry);
            }
            else
            {
                OutputObject obj = new OutputObject();
                obj.Number = entry.ErrorNumber;
                obj.Type = entry.Type;
                obj.Add(entry);
                _DictOfObjects.Add(entry.ErrorNumber, obj);
            }
        }

        public Dictionary<string, OutputObject> GetDict()
        {
            return _DictOfObjects;
        }

        public int NrOfEntries()
        {
            return _DictOfObjects.Count;
        }
    }

    // class for reading settings file
    public class GetSettings
    {
        private string directory;
        private string fnSettings;
        private string exceptString;
        public string ExceptionInfo { get { return exceptString; } }
        public string SettingsFile { get { return fnSettings; } }

        public GetSettings()
        {
            directory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            string exe = Path.GetFileName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            fnSettings = directory + "\\" + exe.Replace(".exe", ".set");
        }

        public Dictionary<string, string> LoadFromFile()
        {
            Dictionary<string, string> dictSettings = new Dictionary<string, string>();
            try
            {
                if (File.Exists(fnSettings))
                {
                    string[] param = File.ReadAllLines(fnSettings);
                    dictSettings = ParseSettings(param);
                }
            }
            catch (Exception ex)
            {
                exceptString = ex.ToString();
            }
            return dictSettings;
        }

        private Dictionary<string, string> ParseSettings(string[] settings)
        {
            Dictionary<string, string> dictSettings = new Dictionary<string, string>();

            try
            {
                foreach (string p in settings)
                {
                    string line = p.Trim();
                    if (line != string.Empty && !line.StartsWith(";") && line.Contains("="))
                    {
                        string[] pv = line.Split(new char[] { '=' });
                        // parameters has to be in the format "name=value", nothing different is allowed!
                        if (pv.Length == 2)
                        {
                            dictSettings.Add(pv[0].Trim().ToLower(), pv[1].Trim());
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                exceptString = ex.ToString();
            }

            return dictSettings;
        }
    }


}
