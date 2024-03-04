-- Create a table w/ values that correspond to bible_data_set.csv
create table bible_main (
	citation VARCHAR(20),
	book VARCHAR(20),
	chapter SMALLINT,
	verse SMALLINT,
	text VARCHAR(700)
);

-- I used dbeaver and the process of copying the csv file into the table
-- was not easy, since it could not find my file as it was in WSL 
-- (dbeaver was on my windows whereas the csv file is on wsl)
-- If no trouble with file location simply use:
-- 'COPY bible_main FROM {csv-file location} DELIMITER ',' CSV HEADER;'
-- **I used the \copy command in psql to acheive the same result

-- Added an id for the verse number relative to the whole Bible ie.
-- Genesis 1:1 will have id 1 as it is the first verse of the Bible
alter table bible_main add column id SERIAL primary key;

-- Creates table bibleBooks having the total number of verses and chapters
-- for each book of the Bible as well as the average number of verses per
-- chapter
create table bibleBooks as
(
	with bibleChapters as (
		select book , COUNT(chapter) as chapterCount
		from bible_main
		group by book, chapter
	)
	select 
		b.book, 
		count(b.chapterCount) chapterCount, 
		sum(b.chapterCount) verseCount,
		floor(sum(b.chapterCount) / count(b.chapterCount)) AvgVersePerChapter
	from bibleChapters b
	group by b.book
	order by chapterCount desc
);