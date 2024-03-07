import pandas as pd
import numpy as np
import collections
import os

#Split the strings in the text column
df = pd.read_csv('bible_data_set.csv')

df = df.assign(
    Split_verse=df.get('text').str.split()
)

def strip_strings_in_lst(lst):
    # turns the list into a format of the array type in postgres 
    # for the csv file, while stripping characters, so only alphabets are
    # present
    returned_lst = '{' + ','.join(np.char.strip(lst, chars=', .:;"?!()')\
        .tolist())+ '}'
    
    # take care of weird case when there is a trailing comma at the end
    # near the bracket
    if returned_lst[-2:] == ',}':
        return returned_lst.replace(',}', '}')
    return returned_lst

cleaned_df = df.assign(
    Split_verse=df.get('Split_verse').apply(strip_strings_in_lst)
).get(['citation', 'book', 'chapter', 'verse', 'Split_verse'])

#Check that the split verse is in the format of the postgres array type
print(cleaned_df.get('Split_verse')[17707])

if os.path.isfile('pandas_csv/cleaned_bible_data.csv') == False:
    cleaned_df.to_csv('pandas_csv/cleaned_bible_data.csv', index=False)

#-----------------------------------------------------------------------------#
#Make a dataframe of all the unique words and the number of occurences 
#in the Bible
    
ctr = collections.Counter()

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
)

if os.path.isfile('pandas_csv/unique_words.csv') == False:
    word_count.to_csv('pandas_csv/unique_words.csv', index=False)

#-----------------------------------------------------------------------------#
#Make a dataframe of all number of words per chapter of the Bible
num_words_df = df.assign(
    Num_words=df.get('Split_verse').apply(len)
)
num_words_df = num_words_df.groupby(['book', 'chapter']).sum().reset_index()\
    .get(['book', 'chapter', 'Num_words'])
if os.path.isfile('pandas_csv/num_words.csv') == False:
    num_words_df.to_csv('pandas_csv/num_words.csv', index=False)
