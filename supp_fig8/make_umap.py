import pandas as pd
import numpy as np
import umap
import matplotlib.pyplot as plt

# Carga tus datos en un DataFrame (reemplaza 'tus_datos.csv' con tu archivo)
df = pd.read_csv('JC_blas/concat_all_go',sep="\t")

# Selecciona las columnas que deseas utilizar para el UMAP
#columnas_seleccionadas = df[['columna1', 'columna2', 'columna3']]  # reemplaza con tus columnas

# Crea el objeto UMAP
reductor = umap.UMAP(n_components=2, random_state=42, n_neighbors=100, min_dist=0.1, metric='cosine')
#reductor = umap.UMAP(n_components=2, n_neighbors=100, min_dist=0.1, metric='cosine')

# Aplica el UMAP al conjunto de datos
umap_datos = reductor.fit_transform(df)

# Convierte el resultado en un DataFrame
df_umap = pd.DataFrame(umap_datos, columns=['UMAP_1', 'UMAP_2'])

# Visualiza el resultado con Matplotlib
plt.figure(figsize=(10, 8))
plt.scatter(df_umap['UMAP_1'], df_umap['UMAP_2'])
plt.title('UMAP')
plt.xlabel('UMAP_1')
plt.ylabel('UMAP_2')
plt.show()
#plt.savefig('all_UMAP.pdf')
