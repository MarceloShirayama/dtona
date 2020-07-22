import pandas as pd
import sqlalchemy
import os
from sklearn import tree, metrics


EP_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.dirname(EP_DIR)
BASE_DIR = os.path.dirname(SRC_DIR)
DATA_DIR = os.path.join(BASE_DIR, 'data')

def import_query(path, **kwargs):
    with open(path, 'r', **kwargs) as file_open:
        result = file_open.read()
    return result

def connect_db():
    return sqlalchemy.create_engine('sqlite:///' \
        + os.path.join(DATA_DIR, 'olist.db'))

query = import_query(os.path.join(EP_DIR, 'create_safra.sql'))

con = connect_db()

# Os dados!!!
df = pd.read_sql(query, con)
columns = df.columns.tolist()

# Variáveis a serem removidas
to_remove = ['seller_id', 'seller_city']

# Variável alvo
target = 'flag_model'

# Remoção das variáveis
for i in to_remove + [target]:
    columns.remove(i)

# Definição dos tipos de variáveis
cat_features = df[columns].dtypes[df[columns].dtypes == \
    'object'].index.tolist()
num_features = list(set(columns) - set(cat_features))

# Treinando o algorítmo de árvore de decisão
clf = tree.DecisionTreeClassifier(max_depth=10)
clf.fit(df[num_features], df[target])

y_pred = clf.predict(df[num_features])
y_prob = clf.predict_proba(df[num_features])

confusion_matrix = metrics.confusion_matrix(df[target], y_pred)

features_importance = pd.Series(
    clf.feature_importances_,
    index=num_features
    )
features_importance = features_importance.sort_values(ascending=False)

