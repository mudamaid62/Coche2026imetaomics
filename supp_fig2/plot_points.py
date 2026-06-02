import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# 1. Prepare your data (Example: X, Y, and Category columns)
df = pd.read_csv('all_best_threshold_potential_blas_venn.m8', sep='\t')

# 2. Set plot style
sns.set_theme(style="whitegrid")

# 3. Create the plot
# 'hue' tells seaborn to create a separate line for each unique value in that column
plt.figure(figsize=(10, 10))
sns.scatterplot(data=df, x='pident', y='tcov', hue='class', marker='o')

# 4. Add labels and title
plt.title('Potential BLAs')
plt.xlabel('Identity (%)')
plt.ylabel('Target Coverage')
plt.legend(title='Target Class')

# 5. Show or save the plot
plt.savefig("potential_by_class.pdf",format="pdf",bbox_inches="tight",dpi=300)
