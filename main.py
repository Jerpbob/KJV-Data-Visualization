import pandas as pd
import numpy as np
import collections

#Make a dataframe of all the unique words and the number of occurences 
#in the Bible
ctr = collections.Counter()

df = pd.read_csv('bible_data_set.csv')

df = df.assign(
    Split_verse=df.get('text').str.split()
)
verse_arr = np.array(df.Split_verse)
verses = []
stripped_verse = []

for verse in verse_arr:
    verses.append(np.array(verse))

for verse in verses:
    stripped_verse.append(np.char.strip(verse, chars=', .:;"?!)('))

final_verses = []

for verse in stripped_verse:
    final_verses.append(verse.tolist())

for verse in final_verses:
    ctr.update(verse)

word_count = pd.DataFrame.from_records(
    ctr.most_common(), columns=['word','count']
).head(100)

print(word_count.to_string())

#Make a dataframe of all number of words per chapter of the Bible
df = df.assign(
    Num_words=df.get('Split_verse').apply(len)
)
grouped_df = df.groupby(['book', 'chapter']).sum().reset_index()\
    .get(['book', 'chapter', 'Num_words'])
print(grouped_df.to_string())