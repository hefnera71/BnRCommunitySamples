using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ASOutputAnalyse
{
    public partial class FrmUserWarnings : Form
    {
        public FrmUserWarnings(List<string> ListUserWarnings)
        {
            InitializeComponent();

            foreach (string s in ListUserWarnings)
            {
                string[] sParts = s.Split('|');
                if (sParts.Length == 6)
                {
                    dataGridView1.Rows.Add(sParts);
                }
            }
        }
    }
}
