import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from decimal import Decimal

# Definindo o csv
df_produtos = pd.read_csv('Datasets/produtos_raw.csv')

# Vamos consertar as categorias primeiro
# Para facilitar primeiro vou tirar toda capitalização, todos os acentos, 
# e todos os espaços, então vou comparar com as categorias desejadas também já limpas
categories = ['ancoragem', 'eletronicos', 'propulsao']
df_produtos['actual_category'] = (
    df_produtos['actual_category']
    .str.lower()
    .str.normalize('NFKD')
    .str.encode('ascii', errors='ignore')
    .str.decode('utf-8')
    .str.replace(' ', '', regex=False)
)

# Depois de classificar eu uso um dicionario para ficar do jeito ideal
mapa_categorias = {
    'ancoragem': 'ancoragem',
    'eletronicos': 'eletrônicos',
    'propulsao': 'propulsão'
}

# Como existem muitos erros de gramatica, vou usar n-grams para classificar qual
# categoria é mais provavel, ele divide a palavra em partes menores para identificar
# Vou dividir a palavra entre 2 e 4 letras 

vectorizer = TfidfVectorizer(analyzer='char_wb', ngram_range=(2, 4))
train_texts = categories + df_produtos['actual_category'].unique().tolist()
vectorizer.fit(train_texts)
target_vectors = vectorizer.transform(categories)
values_vectors = vectorizer.transform(df_produtos['actual_category'])
similarity = cosine_similarity(values_vectors, target_vectors)

# Eu usei a coluna confidence para revisar manualmente os casos mais dificeis
# Mas parecem estar todos certos

df_produtos['category_predicted'] = [categories[i] for i in np.argmax(similarity, axis=1)]
df_produtos['confidence'] = np.max(similarity, axis=1)

# Usando o dicionario que mencionei antes
df_produtos['category'] = df_produtos['category_predicted'].map(mapa_categorias)

# Agora vou tratar rapidamente o preço
# Usei decimal por se tratar de dinheiro para não dar problema de float
df_produtos['price'] = (
    df_produtos['price']
    .str.replace('R$', '', regex=False)
    .str.strip()
    .apply(Decimal)
)

# Vou ajustar os nomes e a ordem do df final por consistencia e estetica
# Identificar que price originalmente era em reais
df_produtos_limpo = (
    df_produtos
    .rename(columns={'code': 'id_product', 'name': 'product_name', 'price': 'brl_price'})
    [['id_product', 'product_name', 'category','brl_price']]
)

# Remover as duplicatas
antes = len(df_produtos_limpo)
df_produtos_limpo = df_produtos_limpo.drop_duplicates()
depois = len(df_produtos_limpo)

print(f"Removidas: {antes - depois} linhas duplicadas")
print(df_produtos_limpo.head())
print(df_produtos_limpo.info())