import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import umap.umap_ as umap


# Carga los datos en un DataFrame
df = pd.read_csv('all_go_umap_input',sep="\t")

# Crea el objeto UMAP
reductor = umap.UMAP(n_components=2, random_state=42, n_neighbors=100, min_dist=0.1, metric='cosine')

# Aplica el UMAP al conjunto de datos
umap_datos = reductor.fit_transform(df.iloc[:, 8:])

# Añade los valores de UMAP a la dataframe
df_umap = pd.DataFrame(umap_datos, columns=['UMAP_1', 'UMAP_2'])
df_con_umap = pd.concat([df.iloc[:, :8], df_umap], axis=1)


# NOVELTY
# Reemplazar los valores "-" por NaN en la columna 'UniprotKB_novelty%'
df_con_umap['UniprotKB_novelty%'] = pd.to_numeric(df_con_umap['UniprotKB_novelty%'], errors='coerce')  # Convierte "-" a NaN

# Crear una paleta continua basada en los valores numéricos de UniprotKB_novelty%
norm = plt.Normalize(df_con_umap['UniprotKB_novelty%'].min(), df_con_umap['UniprotKB_novelty%'].max())  # Normaliza los valores entre min y max
palette = sns.color_palette("rocket", as_cmap=True)

# Crear el gráfico UMAP
plt.figure(figsize=(10, 8))

# Dibuja primero los puntos con NaN (que representarán los "-") en blanco
sns.scatterplot(x='UMAP_1', y='UMAP_2', data=df_con_umap[df_con_umap['UniprotKB_novelty%'].isna()], 
                color='white', s=100, edgecolor="black", linewidth=0.5, label='UniprotKB_novelty% = "-"')

# Ahora dibuja los puntos con valores numéricos
sns.scatterplot(x='UMAP_1', y='UMAP_2', hue='UniprotKB_novelty%', data=df_con_umap.dropna(subset=['UniprotKB_novelty%']), 
                palette=palette, s=100, edgecolor="black", linewidth=0.5, hue_norm=norm)

# Añadir títulos y etiquetas
plt.title('UMAP with UniprotKB_novelty% (white for "-")', fontsize=16)
plt.xlabel('UMAP_1', fontsize=12)
plt.ylabel('UMAP_2', fontsize=12)

# Añadir barra de colores solo para los valores numéricos
norm = plt.Normalize(df_con_umap['UniprotKB_novelty%'].min(), df_con_umap['UniprotKB_novelty%'].max())
sm = plt.cm.ScalarMappable(cmap="rocket", norm=norm)
sm.set_array([])  # Configurar un array vacío para la colorbar
#plt.colorbar(sm, label='UniprotKB_novelty%')
plt.legend(title='NCBI Novelty', bbox_to_anchor=(1.05, 1), loc='upper left')  # Coloca la leyenda fuera del gráfico

# Guardar el gráfico en formato PDF
plt.savefig('umap_UniprotKB_novelty_colored_with_white.pdf')

# Mostrar el gráfico
plt.show()

# CONSENSUS CLASS

palette = sns.color_palette("hls", df_con_umap['Consensus_class'].nunique()) 
# Crear el gráfico UMAP
plt.figure(figsize=(10, 8))
sns.scatterplot(x='UMAP_1', y='UMAP_2', hue='Consensus_class', data=df_con_umap, palette=palette, s=100, edgecolors= "black", linewidth=0.5)
# Añadir títulos y etiquetas
plt.title('Class', fontsize=16)
plt.xlabel('UMAP_1', fontsize=12)
plt.ylabel('UMAP_2', fontsize=12)
plt.legend(title='Consensus_class', bbox_to_anchor=(1.05, 1), loc='upper left')  # Coloca la leyenda fuera del gráfico
# Guardar el gráfico en formato PDF
plt.savefig('umap_Consensus_class_colored.pdf')
# Mostrar el gráfico
plt.show()

# FAMILY

palette = sns.color_palette("hls", df_con_umap['Family'].nunique()) 
# Crear el gráfico UMAP
plt.figure(figsize=(10, 8))
sns.scatterplot(x='UMAP_1', y='UMAP_2', hue='Family', data=df_con_umap, palette=palette, s=100, edgecolors= "black", linewidth=0.5)
# Añadir títulos y etiquetas
plt.title('Family', fontsize=16)
plt.xlabel('UMAP_1', fontsize=12)
plt.ylabel('UMAP_2', fontsize=12)
plt.legend(title='Consensus_class', bbox_to_anchor=(1.05, 1), loc='upper left')  # Coloca la leyenda fuera del gráfico
# Guardar el gráfico en formato PDF
plt.savefig('umap_Family_colored.pdf')
# Mostrar el gráfico
plt.show()
