import pandas as pd

df = pd.read_csv('bible_data_set.csv')

df = df.assign(
    Split_verse=df.get('text').str.split()
)

df = df.assign(
    Num_words=df.get('Split_verse').apply(len)
)

grouped_df = df.groupby(['book', 'chapter']).sum().reset_index()\
    .get(['book', 'chapter', 'Num_words'])
print(grouped_df.to_string)