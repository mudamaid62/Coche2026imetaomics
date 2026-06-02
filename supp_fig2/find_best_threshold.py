# Find the threshold with the highest MCC
import pandas as pd
import matplotlib.pyplot as plt
# 1. Load the data Replace 'roc_output.tsv' with the filename where you saved the Perl output
df = pd.read_csv('hmm_ROC_table', sep='\t')
best_row = df.loc[df['MCC'].idxmax()] 
print(f"Optimal Threshold (by MCC): {best_row['Threshold']}")
print(f"Corresponding E-value: {best_row['e-value']}")
