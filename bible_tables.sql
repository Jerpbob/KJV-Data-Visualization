-- Create a table w/ values that correspond to bible_data_set.csv
create table bible_main (
	citation VARCHAR(20),
	book VARCHAR(20),
	chapter SMALLINT,
	verse SMALLINT,
	text VARCHAR(700)
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