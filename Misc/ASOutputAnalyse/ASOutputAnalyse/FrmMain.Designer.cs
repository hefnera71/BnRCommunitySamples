namespace ASOutputAnalyse
{
    partial class FrmMain
    {
        /// <summary>
        /// Erforderliche Designervariable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Verwendete Ressourcen bereinigen.
        /// </summary>
        /// <param name="disposing">True, wenn verwaltete Ressourcen gelöscht werden sollen; andernfalls False.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Vom Windows Form-Designer generierter Code

        /// <summary>
        /// Erforderliche Methode für die Designerunterstützung.
        /// Der Inhalt der Methode darf nicht mit dem Code-Editor geändert werden.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnOpenLogFile = new System.Windows.Forms.Button();
            this.treeView1 = new System.Windows.Forms.TreeView();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.chkSaveResult = new System.Windows.Forms.CheckBox();
            this.webBrowser1 = new System.Windows.Forms.WebBrowser();
            this.label1 = new System.Windows.Forms.Label();
            this.chkSkipMessages = new System.Windows.Forms.CheckBox();
            this.lblHelpPath = new System.Windows.Forms.Label();
            this.linkOpenLogFileInEditor = new System.Windows.Forms.LinkLabel();
            this.ChkLastBuildOnly = new System.Windows.Forms.CheckBox();
            this.ChkSaveSummaryOnly = new System.Windows.Forms.CheckBox();
            this.linkOpenSettingsInEditor = new System.Windows.Forms.LinkLabel();
            this.linkOpenResultFileInEditor = new System.Windows.Forms.LinkLabel();
            this.SuspendLayout();
            // 
            // btnOpenLogFile
            // 
            this.btnOpenLogFile.Location = new System.Drawing.Point(12, 12);
            this.btnOpenLogFile.Name = "btnOpenLogFile";
            this.btnOpenLogFile.Size = new System.Drawing.Size(143, 23);
            this.btnOpenLogFile.TabIndex = 1;
            this.btnOpenLogFile.Text = "Analyze AS output log file";
            this.btnOpenLogFile.UseVisualStyleBackColor = true;
            this.btnOpenLogFile.Click += new System.EventHandler(this.btnOpenLogFile_Click);
            // 
            // treeView1
            // 
            this.treeView1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.treeView1.Location = new System.Drawing.Point(12, 81);
            this.treeView1.Name = "treeView1";
            this.treeView1.Size = new System.Drawing.Size(740, 150);
            this.treeView1.TabIndex = 2;
            this.treeView1.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treeView1_AfterSelect);
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "output.log";
            // 
            // chkSaveResult
            // 
            this.chkSaveResult.AutoSize = true;
            this.chkSaveResult.Location = new System.Drawing.Point(171, 12);
            this.chkSaveResult.Name = "chkSaveResult";
            this.chkSaveResult.Size = new System.Drawing.Size(88, 17);
            this.chkSaveResult.TabIndex = 3;
            this.chkSaveResult.Text = "Save result...";
            this.chkSaveResult.UseVisualStyleBackColor = true;
            // 
            // webBrowser1
            // 
            this.webBrowser1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.webBrowser1.Location = new System.Drawing.Point(12, 249);
            this.webBrowser1.MinimumSize = new System.Drawing.Size(20, 20);
            this.webBrowser1.Name = "webBrowser1";
            this.webBrowser1.Size = new System.Drawing.Size(740, 236);
            this.webBrowser1.TabIndex = 5;
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(387, 13);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(257, 13);
            this.label1.TabIndex = 6;
            this.label1.Text = "Path to AS help - builder errors file (out of settings file)";
            // 
            // chkSkipMessages
            // 
            this.chkSkipMessages.AutoSize = true;
            this.chkSkipMessages.Location = new System.Drawing.Point(171, 34);
            this.chkSkipMessages.Name = "chkSkipMessages";
            this.chkSkipMessages.Size = new System.Drawing.Size(202, 17);
            this.chkSkipMessages.TabIndex = 7;
            this.chkSkipMessages.Text = "Don\'t show entry type \"Message (-1)\"";
            this.chkSkipMessages.UseVisualStyleBackColor = true;
            // 
            // lblHelpPath
            // 
            this.lblHelpPath.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblHelpPath.AutoSize = true;
            this.lblHelpPath.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHelpPath.Location = new System.Drawing.Point(387, 35);
            this.lblHelpPath.Name = "lblHelpPath";
            this.lblHelpPath.Size = new System.Drawing.Size(301, 13);
            this.lblHelpPath.TabIndex = 8;
            this.lblHelpPath.Text = "NO (VALID) PATH INSIDE SETTINGS, HELP WON\'T WORK";
            // 
            // linkOpenLogFileInEditor
            // 
            this.linkOpenLogFileInEditor.AutoSize = true;
            this.linkOpenLogFileInEditor.Location = new System.Drawing.Point(13, 42);
            this.linkOpenLogFileInEditor.Name = "linkOpenLogFileInEditor";
            this.linkOpenLogFileInEditor.Size = new System.Drawing.Size(156, 13);
            this.linkOpenLogFileInEditor.TabIndex = 9;
            this.linkOpenLogFileInEditor.TabStop = true;
            this.linkOpenLogFileInEditor.Text = "Open AS output log file in editor";
            this.linkOpenLogFileInEditor.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkOpenLogFileInEditor_LinkClicked);
            // 
            // ChkLastBuildOnly
            // 
            this.ChkLastBuildOnly.AutoSize = true;
            this.ChkLastBuildOnly.Location = new System.Drawing.Point(171, 54);
            this.ChkLastBuildOnly.Name = "ChkLastBuildOnly";
            this.ChkLastBuildOnly.Size = new System.Drawing.Size(119, 17);
            this.ChkLastBuildOnly.TabIndex = 10;
            this.ChkLastBuildOnly.Text = "Show only last build";
            this.ChkLastBuildOnly.UseVisualStyleBackColor = true;
            // 
            // ChkSaveSummaryOnly
            // 
            this.ChkSaveSummaryOnly.AutoSize = true;
            this.ChkSaveSummaryOnly.Location = new System.Drawing.Point(254, 12);
            this.ChkSaveSummaryOnly.Name = "ChkSaveSummaryOnly";
            this.ChkSaveSummaryOnly.Size = new System.Drawing.Size(119, 17);
            this.ChkSaveSummaryOnly.TabIndex = 11;
            this.ChkSaveSummaryOnly.Text = "... but summary only";
            this.ChkSaveSummaryOnly.UseVisualStyleBackColor = true;
            // 
            // linkOpenSettingsInEditor
            // 
            this.linkOpenSettingsInEditor.AutoSize = true;
            this.linkOpenSettingsInEditor.Location = new System.Drawing.Point(387, 55);
            this.linkOpenSettingsInEditor.Name = "linkOpenSettingsInEditor";
            this.linkOpenSettingsInEditor.Size = new System.Drawing.Size(273, 13);
            this.linkOpenSettingsInEditor.TabIndex = 12;
            this.linkOpenSettingsInEditor.TabStop = true;
            this.linkOpenSettingsInEditor.Text = "Open settings file in editor (restart needed after changes)";
            this.linkOpenSettingsInEditor.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkOpenSettingsInEditor_LinkClicked);
            // 
            // linkOpenResultFileInEditor
            // 
            this.linkOpenResultFileInEditor.AutoSize = true;
            this.linkOpenResultFileInEditor.Location = new System.Drawing.Point(13, 58);
            this.linkOpenResultFileInEditor.Name = "linkOpenResultFileInEditor";
            this.linkOpenResultFileInEditor.Size = new System.Drawing.Size(117, 13);
            this.linkOpenResultFileInEditor.TabIndex = 13;
            this.linkOpenResultFileInEditor.TabStop = true;
            this.linkOpenResultFileInEditor.Text = "Open result file in editor";
            this.linkOpenResultFileInEditor.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkOpenResultFileInEditor_LinkClicked);
            // 
            // FrmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(764, 497);
            this.Controls.Add(this.linkOpenResultFileInEditor);
            this.Controls.Add(this.linkOpenSettingsInEditor);
            this.Controls.Add(this.ChkSaveSummaryOnly);
            this.Controls.Add(this.ChkLastBuildOnly);
            this.Controls.Add(this.linkOpenLogFileInEditor);
            this.Controls.Add(this.lblHelpPath);
            this.Controls.Add(this.chkSkipMessages);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.webBrowser1);
            this.Controls.Add(this.chkSaveResult);
            this.Controls.Add(this.treeView1);
            this.Controls.Add(this.btnOpenLogFile);
            this.MinimumSize = new System.Drawing.Size(780, 500);
            this.Name = "FrmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "ASOutputAnalyze - V0.3.1";
            this.Shown += new System.EventHandler(this.Form1_Shown);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Button btnOpenLogFile;
        private System.Windows.Forms.TreeView treeView1;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.CheckBox chkSaveResult;
        private System.Windows.Forms.WebBrowser webBrowser1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox chkSkipMessages;
        private System.Windows.Forms.Label lblHelpPath;
        private System.Windows.Forms.LinkLabel linkOpenLogFileInEditor;
        private System.Windows.Forms.CheckBox ChkLastBuildOnly;
        private System.Windows.Forms.CheckBox ChkSaveSummaryOnly;
        private System.Windows.Forms.LinkLabel linkOpenSettingsInEditor;
        private System.Windows.Forms.LinkLabel linkOpenResultFileInEditor;
    }
}

