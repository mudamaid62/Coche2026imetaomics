import pandas as pd 
import matplotlib.pyplot as plt
# 1. Load the data from your Perl script output Ensure the delimiter matches (the script uses \t for tabs)
df = pd.read_csv('test_ROC', sep='\t')
# 2. Preprocess the data The Perl script may output '-' for PPV if there are no positive predictions. We convert these to NaNs and ensure the columns are numeric.
df['PPV'] = pd.to_numeric(df['PPV'], errors='coerce') 
df['TPR'] = pd.to_numeric(df['TPR'], errors='coerce')
# Drop rows with NaNs and sort by Recall (TPR) for a continuous line plot
df_pr = df.dropna(subset=['PPV', 'TPR']).sort_values('TPR')
# 3. Create the plot
plt.figure(figsize=(8, 6)) 
plt.plot(df_pr['TPR'], df_pr['PPV'], color='teal', lw=2, label='HMM Precision-Recall')
# 4. Formatting
plt.xlabel('Recall (True Positive Rate)') 
plt.ylabel('Precision (Positive Predictive Value)') 
plt.title('Precision-Recall Curve') 
plt.xlim([0.0, 1.0]) 
plt.ylim([0.0, 1.05]) 
plt.grid(alpha=0.3, linestyle='--') 
plt.legend(loc="upper right")
# Save or display
plt.savefig('precision_recall_curve.png')
