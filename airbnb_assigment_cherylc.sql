# SQL Assignment - Airbnb

#################################################################################
# Assignment Due Date: Jul 13 @ 06pm                                            #
# Try to answer question in one query, multi-solution and comments are welcome! #
#################################################################################

# Introduction
# -Analysis: Exploring Airbnb guest data to get interesting insights and to answer business questions.
# -Data: Dataset download link: https://weclouddata.s3.amazonaws.com/datasets/hotel/airbnb/airbnb.zip
# -Tools: MySQL (table structure as shown in the tutorial below)
########################################################################################################################
# Questions

# 1: How many unique listings is provided in the calendar table? A.3583
describe calendar;
select count(distinct listing_id) from calendar;

# 2: How many calendar years do the calendar table span? A. This table has data from 2016 to 2017
# (Expected output: e.g., this table has data from 2009 to 2010)
select distinct left(dt,4)  from calendar;


# 3: Find listings that are completely available for the entire year (available for 365 days)
describe listings;
select id, availability_365 from listings
where availability_365 >= 365;

# 4: How many listings have been completely booked for the year (0 days available)?
select count(distinct id),availability_30 from listings
where availability_30 = 0;

# 5: Which city has most listings? A. Boston
describe listings;
select city, count(city) from listings
group by city
order by city desc
limit 1;

# 6: Which street/st/ave has the most number of listings in Boston?
# (Note: beacon street and beacon st should be considered the same street)
select street from listings;
select count(*),city,
replace(replace(replace(REPLACE(street,'Street','St'),'Road', 'Rd'),'Avenue','Ave'),'Court','Ct') as Street1
from listings
where city = 'Boston'
group by city, Street1
order by count(*) desc;

# 7: In the calendar table, how many listings charge different prices for weekends and weekdays?
# Hint: use average weekend price vs average weekday price
describe calendar;
select * from calendar limit 10;
select count(*) from calendar;
select count(distinct listing_id) from calendar;
-- This query seems doing too much in one step
select count(*)
from (select listing_id,
       available,
       avg(case when dayofweek(dt) between 2 and 6 then replace(price,'$','') else 0 end) as Weekdays,
       avg(case when dayofweek(dt) not between 2 and 6 then replace(price,'$','') else 0 end) as Weekends
from calendar
where available = 't'
group by listing_id
having Weekdays > 0 and Weekends > 0) as sub
where Weekdays != Weekends;

-- Split the inner query
select count(*)
from (select listing_id,
       available,avg(Weekdays)-avg(Weekends) as difference
from (select listing_id,
       available,
       case when dayofweek(dt) between 2 and 6 then replace(price,'$','') end as Weekdays,
       case when dayofweek(dt) not between 2 and 6 then replace(price,'$','') end as Weekends
from calendar
where available ='t') as sub1
group by listing_id)as sub2
where difference != 0;

select count(*) as num_of_diff_price
from(
    select listing_id, avg(weekday_price)-avg(weekend_price) as diff
    from
        (select listing_id,
            case
                when dayofweek(dt) = 1 or dayofweek(dt) = 7
                    then replace(price, '$', '')
            end as weekend_price,
            case
                when dayofweek(dt) in (2,3,4,5,6)
                    then replace(price, '$', '')
            end as weekday_price
        from calendar
        where available = 't') as sub_query
    group by listing_id) as sub_query_2
where diff != 0;

########################################################################################################################
# Tutorial - Create Tables
# Create and load calendar table
drop table if exists airbnb.calendar;

create table airbnb.calendar (
    listing_id            bigint,
    dt                    char(10),
    available             char(1),
    price                  varchar(20)
);

truncate airbnb.calendar;

-- load data into the calendar table
load data local infile '/Users/cherylchien/Documents/Bootcamp/1029/airbnb/calendar.csv'
into table airbnb.calendar
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines
;

# test calendar table
select * from airbnb.calendar limit 5;
select * from airbnb.calendar where listing_id=14204600 and dt='2017-08-20';

-- Create listings table
drop table if exists airbnb.listings;
create table airbnb.listings (
    id bigint,
    listing_url text,
    scrape_id bigint,
    last_scraped char(10),
    name text,
    summary text,
    space text,
    description text,
    experiences_offered text,
    neighborhood_overview text,
    notes text,
    transit text,
    access text,
    interaction text,
    house_rules text,
    thumbnail_url text,
    medium_url text,
    picture_url text,
    xl_picture_url text,
    host_id bigint,
    host_url text,
    host_name varchar(100),
    host_since char(10),
    host_location text,
    host_about text,
    host_response_time text,
    host_response_rate text,
    host_acceptance_rate text,
    host_is_superhost char(1),
    host_thumbnail_url text,
    host_picture_url text,
    host_neighbourhood text,
    host_listings_count int,
    host_total_listings_count int,
    host_verifications text,
    host_has_profile_pic char(1),
    host_identity_verified char(1),
    street text,
    neighbourhood text,
    neighbourhood_cleansed text,
    neighbourhood_group_cleansed text,
    city text,
    state text,
    zipcode text,
    market text,
    smart_location text,
    country_code text,
    country text,
    latitude text,
    longitude text,
    is_location_exact text,
    property_type text,
    room_type text,
    accommodates int,
    bathrooms text,
    bedrooms text,
    beds text,
    bed_type text,
    amenities text,
    square_feet text,
    price text,
    weekly_price text,
    monthly_price text,
    security_deposit text,
    cleaning_fee text,
    guests_included int,
    extra_people text,
    minimum_nights int,
    maximum_nights int,
    calendar_updated text,
    has_availability varchar(10),
    availability_30 int,
    availability_60 int,
    availability_90 int,
    availability_365 int,
    calendar_last_scraped varchar(10),
    number_of_reviews int,
    first_review varchar(10),
    last_review varchar(10),
    review_scores_rating text,
    review_scores_accuracy text,
    review_scores_cleanliness text,
    review_scores_checkin text,
    review_scores_communication text,
    review_scores_location text,
    review_scores_value text,
    requires_license char(1),
    license text,
    jurisdiction_names text,
    instant_bookable char(1),
    cancellation_policy varchar(20),
    require_guest_profile_picture char(1),
    require_guest_phone_verification char(1),
    calculated_host_listings_count int,
    reviews_per_month text
);

truncate airbnb.listings;

-- load data into the calendar table
load data local infile '/Users/cherylchien/Documents/Bootcamp/1029/airbnb/listings.csv'
into table airbnb.listings
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines
;

# test calendar table
select * from airbnb.listings limit 5;

# Create and load reviews table
drop table if exists airbnb.reviews;
create table airbnb.reviews (
    listing_id bigint,
    id bigint,
    date varchar(10),
    reviewer_id bigint,
    reviewer_name text,
    comments text
);

load data local infile '/Users/cherylchien/Documents/Bootcamp/1029/airbnb/reviews.csv'
into table airbnb.listings
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines