
namespace ASOutputAnalyse
{
    partial class FrmUserWarnings
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.ColUserPattern = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColEntryNumber = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColText = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColType = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColErrNr = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColLineNumber = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.Red;
            this.label1.Location = new System.Drawing.Point(87, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(415, 17);
            this.label1.TabIndex = 1;
            this.label1.Text = "Some user defined \"error patterns\" were found inside the log file!";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.ForeColor = System.Drawing.SystemColors.ControlText;
            this.label2.Location = new System.Drawing.Point(87, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(673, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Please CHECK them CAREFULLY because even if they do not lead to a compile error, " +
    "they could lead to malfunction!";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::ASOutputAnalyse.Properties.Resources.error;
            this.pictureBox1.Location = new System.Drawing.Point(12, 8);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(57, 50);
            this.pictureBox1.TabIndex = 3;
            this.pictureBox1.TabStop = false;
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToAddRows = false;
            this.dataGridView1.AllowUserToDeleteRows = false;
            this.dataGridView1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ColUserPattern,
            this.ColEntryNumber,
            this.ColText,
            this.ColType,
            this.ColErrNr,
            this.ColLineNumber});
            this.dataGridView1.Location = new System.Drawing.Point(12, 64);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersVisible = false;
            this.dataGridView1.ShowEditingIcon = false;
            this.dataGridView1.Size = new System.Drawing.Size(878, 148);
            this.dataGridView1.TabIndex = 4;
            // 
            // ColUserPattern
            // 
            this.ColUserPattern.HeaderText = "User pattern";
            this.ColUserPattern.Name = "ColUserPattern";
            this.ColUserPattern.Width = 150;
            // 
            // ColEntryNumber
            // 
            this.ColEntryNumber.HeaderText = "Entry nr.";
            this.ColEntryNumber.Name = "ColEntryNumber";
            this.ColEntryNumber.Width = 70;
            // 
            // ColText
            // 
            this.ColText.HeaderText = "Text";
            this.ColText.Name = "ColText";
            this.ColText.ReadOnly = true;
            this.ColText.Width = 400;
            // 
            // ColType
            // 
            this.ColType.HeaderText = "Type";
            this.ColType.Name = "ColType";
            this.ColType.ReadOnly = true;
            // 
            // ColErrNr
            // 
            this.ColErrNr.HeaderText = "Error nr.";
            this.ColErrNr.Name = "ColErrNr";
            this.ColErrNr.ReadOnly = true;
            this.ColErrNr.Width = 70;
            // 
            // ColLineNumber
            // 
            this.ColLineNumber.HeaderText = "File line";
            this.ColLineNumber.Name = "ColLineNumber";
            this.ColLineNumber.ReadOnly = true;
            this.ColLineNumber.Width = 70;
            // 
            // FrmUserWarnings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(902, 224);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(800, 180);
            this.Name = "FrmUserWarnings";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "ASOutputAnalyse - User defined error patterns";
            this.TopMost = true;
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColUserPattern;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColEntryNumber;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColText;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColType;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColErrNr;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColLineNumber;
    }
}