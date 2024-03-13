-- a view to showcase the number of words in a chapter in the order it shows in 
-- the Bible
create view num_word_per_chapter as
(
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
order by book_num, chapter
);

select * from num_word_per_chapter;

-- query to find the average and sum of words read per day when one reads
-- 4 chapters a day
with final_q as 
(
	select 
		t.row,
		t.book, 
		avg(t.num_words) over (rows between current row and 3 following) as avg_num,
		sum(t.num_words) over (rows between current row and 3 following) as sum_num
	from (
		select *, row_number() over(order by book_num, chapter) as row 
		from num_word_per_chapter 
	) t
)
select
	row_number() over (order by fq.row ASC) as day,
	fq.book,
	fq.avg_num,
	fq.sum_num
from final_q fq
where fq.row % 4 = 1;

