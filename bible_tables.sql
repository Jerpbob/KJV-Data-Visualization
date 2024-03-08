-- Create a table w/ values that correspond to bible_data_set.csv 
create table bible_main (
	citation VARCHAR(20),
	book VARCHAR(20),
	chapter SMALLINT,
	verse SMALLINT,
	text VARCHAR(700)
);

-- Create another table w/ values that correspond to cleaned_bible_data.csv
create table cleaned_bible_main (
	citation VARCHAR(20),
	book VARCHAR(20),
	chapter smallint,
	verse smallint,
	text varchar(50)[]
);
-------------------------------------------------------------------------
-- I used dbeaver and the process of copying the csv file into the table
-- was not easy, since it could not find my file as it was in WSL 
-- (dbeaver was on my windows whereas the csv file is on wsl)
-- If no trouble with file location simply use:
-- 'COPY bible_main FROM {csv-file location} DELIMITER ',' CSV HEADER;'
-- **I used the \copy command in psql to acheive the same result
-------------------------------------------------------------------------

-- Added an id for the verse number relative to the whole Bible ie.
-- Genesis 1:1 will have id 1 as it is the first verse of the Bible
alter table bible_main add column id SERIAL primary key;

-- Creates table bibleBooks having the total number of verses and chapters
-- for each book of the Bible as well as the average number of verses per
-- chapter
create table bible_books as
(
	with bible_chapters as (
		select book , COUNT(chapter) as chapter_count
		from bible_main
		group by book, chapter
	)
	select 
		b.book, 
		count(b.chapterCount) chapterCount, 
		sum(b.chapterCount) verseCount,
		floor(sum(b.chapterCount) / count(b.chapter_count)) avg_verse_per_chapter
	from bible_chapters b
	group by b.book
	order by chapter_count desc
);

-- Added primary key to biblebooks table and added a new column to insert
-- the book number in correlation to its placement in the Bible
-- ** I had to manually update each row to add the book number **
alter table bible_Books add primary key (book);
alter table bible_books add book_num SMALLINT;

-- Create an OBT (one big table) from cleaned_bible_main and bible_main tables
create table bible as
(
select 
	cbm.verse_id, 
	cbm.citation, 
	cbm.book, 
	cbm.chapter, 
	cbm.verse, 
	bm.text as text_with_symbols, 
	array_to_string(cbm.text, ' ') as text_without_symbols,
	unnest(cbm.text) as case_sensitive_word,
	lower(unnest(cbm.text)) non_case_sensitive_word
from cleaned_bible_main cbm
inner join bible_main bm on cbm.verse_id = bm.verseid
);

alter table bible add column word_id serial primary key;
alter table bible 
add constraint fk_book
foreign key (book) references bible_books(book);

-- a query to showcase the number of words in a chapter in the order it shows in 
-- the Bible
with grouped_bible as (
	select 
		verse_id, 
		citation, 
		book, 
		chapter,
		text_with_symbols, 
		count(case_sensitive_word) as word_count
	from bible
	group by verse_id, citation, book, chapter, text_with_symbols
)
select bb.book_num, b.book, b.chapter, b.num_words
from (
	select 
		book, 
		chapter, 
		sum(word_count) num_words
	from grouped_bible
	group by book, chapter
	order by book, chapter
	) b
left join bible_books bb on bb.book = b.book
order by book_num, chapter;