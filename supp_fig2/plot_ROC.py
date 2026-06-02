import pandas as pd 
import matplotlib.pyplot as plt
# 1. Load the data Replace 'roc_output.tsv' with the filename where you saved the Perl output
df = pd.read_csv('hmm_ROC_table', sep='\t')
# 2. Sort values by FPR to ensure the line plots correctly
df = df.sort_values('FPR')
# 3. Initialize the plot
plt.figure(figsize=(10, 10))
# Plot the ROC Curve
plt.plot(df['FPR'], df['TPR'], color='darkorange', lw=3, label='HMMER ROC curve')
# Plot the diagonal line (Random Classifier)
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--', label='Random')
# Formatting
plt.xlim([0.0, 1.1]) 
plt.ylim([0.0, 1.1]) 
plt.xlabel('False Positive Rate (1 - Specificity)') 
plt.ylabel('True Positive Rate (Sensitivity)') 
plt.title('Receiver Operating Characteristic (ROC)') 
plt.legend(title='ROC')
plt.grid(alpha=0.3)
plt.savefig("hmm_ROC.pdf",format="pdf",bbox_inches="tight",dpi=300)
