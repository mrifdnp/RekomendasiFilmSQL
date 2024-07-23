-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 23, 2024 at 12:07 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uas`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMoviesByGenreAndYear` (IN `genreName` VARCHAR(255), IN `releaseYear` YEAR)   BEGIN
    DECLARE genreCount INT;
    
    SELECT COUNT(*) INTO genreCount
    FROM genres
    WHERE genre_name = genreName;
    
    IF genreCount = 0 THEN
        SELECT 'Genre tidak ditemukan' AS message;
    ELSE
        CASE
            WHEN releaseYear < 2000 THEN
                SELECT 'Tahun rilis harus 2000 atau setelahnya' AS message;
            WHEN releaseYear > YEAR(CURDATE()) THEN
                SELECT 'Tahun rilis tidak boleh lebih dari tahun sekarang' AS message;
            ELSE
                SELECT m.title, d.name AS director, m.release_year
                FROM movies m
                JOIN directors d ON m.director_id = d.director_id
                JOIN movie_genres mg ON m.movie_id = mg.movie_id
                JOIN genres g ON mg.genre_id = g.genre_id
                WHERE g.genre_name = genreName AND m.release_year = releaseYear
                ORDER BY m.title;
        END CASE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTopRatedMovies` ()   BEGIN
	DECLARE done INT DEFAULT False;
    DECLARE movieTitle VARCHAR (255);
    DECLARE avgRating DECIMAL (3,2);
    
    DECLARE movieCursor CURSOR FOR
    	SELECT m.title, AVG(r.rating) as avg_rating
        from movies m 
        JOIN reviews r on m.movie_id = r.movie_id
        GROUP by m.movie_id
        HAVING AVG(r.rating)>7
        ORDER BY avg_rating DESC
        LIMIT 5;
    DECLARE CONTINUE HANDLER FOR NOT found SET done = true;
    
    CREATE TEMPORARY TABLE if NOT EXISTS top_rated_movies (
        title Varchar(255),
        average_rating decimal(3,2));
        
     OPEN movieCursor;
     
     read_loop: LOOP
     	FETCH movieCursor INTO movieTitle, avgRating;
        IF done THEN
        	Leave read_loop;
            END IF;
         INSERT INTO top_rated_movies(title,average_rating) VALUES (movieTitle, avgRating);
         END LOOP;
         
         CLOSE movieCursor;
         
         SELECT * FROM top_rated_movies;
         
         Drop TEMPORARY TABLE if EXISTS top_rated_movies;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `AverageRatinglyGenreAndYear` (`genre_name` VARCHAR(255), `release_year` YEAR) RETURNS DECIMAL(3,2) DETERMINISTIC BEGIN
DECLARE avg_rating DECIMAL(3,2);
SELECT AVG(r.rating) INTO avg_rating
FROM reviews r
JOIN movies m ON m.movie_id = m.movie_id
JOIN movie_genres mg on m.movie_id = m.movie_id 
JOIN genres g ON mg.genre_id=g.genre_id
WHERE g.genre_name = genre_name and m.release_year = release_year;
RETURN COALESCE(avg_rating, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountMovies` () RETURNS INT(11)  BEGIN
	DECLARE total INT;
    SELECT COUNT(*) INTO total from movies;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `directors`
--

CREATE TABLE `directors` (
  `director_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `birthdate` date DEFAULT NULL,
  `nationality` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `directors`
--

INSERT INTO `directors` (`director_id`, `name`, `birthdate`, `nationality`) VALUES
(1, 'Joko Anwar', '1976-01-03', 'Indonesia'),
(2, 'Hanung Bramantyo', '1975-10-01', 'Indonesia'),
(3, 'Bayu Skak', '1993-11-13', 'Indonesia'),
(4, 'Yongki Ongestu', NULL, 'Indonesia'),
(5, 'Anggy Umbara', '1980-10-21', 'Indonesia'),
(6, 'Rako Prijanto', '1973-05-04', 'Indonesia'),
(7, 'Lele Laila', NULL, 'Indonesia'),
(8, 'Hadrah Daeng Ratu', NULL, 'Indonesia'),
(9, 'Charles Gozali', NULL, 'Indonesia'),
(10, 'Muhadkly Acho', NULL, 'Indonesia'),
(11, 'Asep', NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `director_name`
-- (See below for the actual view)
--
CREATE TABLE `director_name` (
`director_id` int(11)
,`name` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `genres`
--

CREATE TABLE `genres` (
  `genre_id` int(11) NOT NULL,
  `genre_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `genres`
--

INSERT INTO `genres` (`genre_id`, `genre_name`) VALUES
(1, 'Animation'),
(2, 'Biography'),
(3, 'Comedy'),
(4, 'Crime'),
(5, 'Documentary'),
(6, 'Drama'),
(7, 'Family'),
(8, 'Fantasy'),
(9, 'Film-Noir'),
(10, 'Game-Show'),
(11, 'Short'),
(12, 'History'),
(13, 'Horror'),
(14, 'Music'),
(15, 'Musical'),
(16, 'Mystery'),
(17, 'News'),
(18, 'Romance'),
(19, 'Exclude'),
(20, 'Sci-Fi'),
(21, 'Sport'),
(22, 'Talk-Show'),
(23, 'Thriller'),
(24, 'War'),
(25, 'Western'),
(26, 'Action'),
(27, 'Adventure');

-- --------------------------------------------------------

--
-- Stand-in structure for view `horror_movies`
-- (See below for the actual view)
--
CREATE TABLE `horror_movies` (
`movie_id` int(11)
,`title` varchar(255)
,`director_id` int(11)
,`release_year` year(4)
,`genre_id` int(11)
,`synopsis` text
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `horror_movies_title`
-- (See below for the actual view)
--
CREATE TABLE `horror_movies_title` (
`movie_id` int(11)
,`title` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `movie_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `director_id` int(11) NOT NULL,
  `release_year` year(4) NOT NULL,
  `genre_id` int(11) DEFAULT NULL,
  `synopsis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`movie_id`, `title`, `director_id`, `release_year`, `genre_id`, `synopsis`) VALUES
(1, 'Joko Anwars Nightmares and Daydreams', 1, '2024', 16, 'Ordinary people encountering strange phenomenons that may be keys to the answer about the origin of our world and the imminent threat we will soon face.'),
(2, 'Ipar Adalah Maut', 2, '2024', 6, 'Nisa and Aris initially happy household will be shaken by the appearance of Nisa\'s younger sibling who lives with them.'),
(3, 'Sekawan Limo', 3, '2024', 6, 'Trapped on Mount Madyopuro because they violated a myth, Bagas, Lenni, Dicky, Juna and Andrew became suspicious of each other that one of them was a ghost.'),
(4, 'Kuyang', 4, '2024', 13, 'Film menakutkan dan seram serta horror'),
(5, 'Munkar', 5, '2024', 13, 'An oddity that caused unrest at an Islamic boarding school occurred since one of the female students returned.'),
(6, 'Pemandi Jenazah', 8, '2024', 13, 'Lela, a mortician, grapples with uncovering the truth behind her mother\'s mysterious deaths while haunted by spirits and burdened by the weight of untold secrets'),
(7, 'Pemukiman Setan\r\n', 9, '2023', 13, 'A woman, a traumatized victim of family violence and economic hardship, was forced to join three friends in robbing an antique house.'),
(8, 'Monster', 6, '2023', 13, 'Alana and Rabin, two friends who were kidnapped by a monster. With no other choice, they had to fight by any means necessary.'),
(9, 'Agak Lain', 10, '2024', 3, 'An old man dies in a failing haunted house ride. The operators bury his body on site, turning it into a popular attraction.'),
(10, 'Siksa Kubur', 1, '2024', 13, 'Telling about the punishment of the grave which occurred after a man was buried.');

-- --------------------------------------------------------

--
-- Table structure for table `movie_genres`
--

CREATE TABLE `movie_genres` (
  `movie_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `movie_genres`
--

INSERT INTO `movie_genres` (`movie_id`, `genre_id`) VALUES
(1, 6),
(1, 13),
(1, 16),
(2, 6),
(2, 18),
(3, 3),
(3, 13),
(4, 6),
(4, 13),
(4, 23),
(5, 13),
(6, 6),
(6, 13),
(6, 23),
(7, 8),
(7, 13),
(8, 13),
(8, 16),
(8, 23),
(9, 3),
(10, 6),
(10, 13),
(10, 23);

-- --------------------------------------------------------

--
-- Table structure for table `profiles`
--

CREATE TABLE `profiles` (
  `profile_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `bio` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `profiles`
--

INSERT INTO `profiles` (`profile_id`, `user_id`, `bio`) VALUES
(1, 1, 'Reviewer film pemula'),
(2, 2, 'Ingin jadi aktor'),
(4, 3, 'udah jago review film'),
(5, 4, 'ribuan film sudah saya review'),
(6, 5, 'selain review film,saya juga suka review makanan');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `movie_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 10),
  `comment` text DEFAULT NULL,
  `review_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`review_id`, `movie_id`, `user_id`, `rating`, `comment`, `review_date`) VALUES
(1, 10, 1, 8, 'Horror movies. Often a genre synonymous with jump scares, gore, and mindless entertainment. While these elements can be thrilling, they rarely delve into the deeper recesses of the human psyche. They seldom grapple with the existential questions that gnaw at us in the quiet hours, the ones that keep us up at night. This is precisely why Joko Anwar\'s Siksa Kubur a.k.a. Grave Torture, struck such a profound chord with me. It dared to be different, to transcend the genre\'s limitations and offer a horror experience unlike any other.\r\n', '2024-07-22 10:51:18'),
(2, 1, 1, 7, 'As an Indonesian, I\'m surprised we actually got this kind of quality.\r\n\r\nI haven\'t watched a lot of Indonesian movie lately (or ever actually) because I really can\'t get into them. Usually the acting is really bad and the dialogues are cringe as well. The production is also usually pretty bad and low budget...\r\n\r\nAnd so, I was surprised how delightful this series was. The production was definitely a step up from usual. Hell, the cgi was actually pretty good too and wow, the story is not bad at all.\r\n\r\nIt is far from perfect, like some episodes are stronger than the other (for me personally I like ep 3 the most, then 2), and there were some wtf moments that are not that great and dragged out (and don\'t get me started on the last episode and that girl who only has 1 emotion and can barely act...)\r\n\r\nBut overall, it was a pleasant watch. I love the horror stories and the Lovecraftian vibe. I won\'t mind having another s2 but will need some tighter story and scenes.', '2024-07-22 10:53:17'),
(3, 1, 2, 7, 'I dont usually leave review for a series but I feel I have to for this one.\r\n\r\nThis is a departure from the highly polished western series. It has unique dingy aesthetics that is special to Indonesian movies like the raid or satan\'s slave that is distinct from high budget productions. The dialogue maybe awkward at times but the story and idea is superb and the acting is decent.\r\n\r\nThe dub quality is excellent and you can see that each episodes is produced with passion. There is some aspect that western audience might not be able to relate to because its uniquely Indonesian but give it a whirl, it wont disappoint you', '2024-07-22 10:54:03'),
(4, 1, 3, 7, 'Not saying I\'m completely disappointed, well maybe a bit, but I just to imagine it were that based on what I expected and speculated from the trailer and not some kind of interconnected stories with the climax at the final episode, it would have been more interesting to me. I have no problem with the CGI, for a non-hollywood production series it\'s kinda okay, though I agree it can be improved for the later seasons. Like all Joko Anwar\'s projects, it brought his seemingly untamable bias of some rigid acting and dialogue in some parts by some of the actors. Scoring is fine and the plots are as usual: slightly better in concept than execution. But without Joko, who would be so brave and competent enough to pull this off in Indonesia? All in all, I\'m satisfied and not feeling a little bit of regret spending my time finishing this series off in one go', '2024-07-22 10:54:53'),
(5, 1, 4, 5, 'The story is nothing original. Joko Anwar created this story, from an existing plot: Silence of the Lamb, Kimi no Nawa, Saw, Love, Death and Robot: Jibaro. Episodes one to 6, can be enjoyed. Until it was finally ruined by episode 7. Where this film became an ordinary superhero film. Episode 7 also has the worst plot and the worst acting quality. No longer special. I think Joko Anwar is an overrated director. His fans also said that his bad films were good. Joko Anwar should be able to develop more original stories, not trapped by global trends. He should know that the superhero genre is starting to be abandoned. Changing this series from the horror, mystery, sci-fi genre to the superhero genre is a bad choice. Moreover, this series feels very rushed to finish.', '2024-07-22 10:56:18'),
(6, 1, 5, 4, 'Some stories were wasted potentials for better plot development. Three stories just got weaker and worse.... Didn\'t realize they were suppose to be connected into second last ep. This such a huge letdown. Even when the last story was somewhat promising to start.... That ending... No.... Just no. Please stick to horror. If you can\'t do it right, just don\'t try to overlap genres. I just think i wasted entire 6 hours watching this and i don\'t even know why. I can even bypass the not so perfect cgi or some of the weaker dialogue, but the plot just misses on so so so many levels!!! Why?! This is not great!!', '2024-07-22 10:56:50'),
(7, 2, 1, 8, 'belum nonton dan ga berniat nonton juga sebetulnya.\r\n\r\nTapi pas baca judul dan ulasan film tersebut sejak pertama, langsung mengingatkan pada sebuah kisah nyata yang saya tahu, mirip.\r\n\r\nIni kisah teman baik ibu saya, sejak jaman sekolah. Saya ingat wajahnya, sangat cantik, agak ada wajah indo nya, hidungnya mancung, matanya besar, tiap kali dia datang, saya selalu tak berhenti menatap, saya suka hidungnya.\r\n\r\nDia juga datang dari keluarga berada, menikahi seorang laki - laki yang seingat saya juga ganteng, dengan karir sukses, dikaruniai 2 anak, yang terbesar perempuan, seusia kakak saya, yang lebih kecil laki - laki, beberapa tahun lebih tua dari usia saya.\r\n\r\nHidupnya terlihat bahagia, sejahtera, gemah ripah loh jinawi lah pokoknya, rumahnya sangat luas seingatku di tengah kota Bandung, lalu kemana - mana selalu ada mobil dan supir yang tersedia. Sampai dia menerima keponakannya, anak kakak tertuanya tinggal bersama , untuk kuliah karena keluarga kakaknya menetap di surabaya, jadi dengan alasan keamanan, daripada kost, maka dititipkanlah keponakan berusia 19 tahun dirumahnya.', '2024-07-22 10:59:21'),
(8, 2, 2, 9, 'Saya melihat film Ipar Adalah Maut (IAM) di bioskop pada jam penayangan terakhir, yaitu sekitar pukul 21.05 WIB. Di jam tersebut, kursi bioskop hanya terisi sekitar sepertiganya. Meski demikian, saking apik dan mengenanya film tersebut, seluruh penonton baik pria atau wanita meramaikan seisi ruangan dengan caci maki dan teriakan saat scene tertentu. Hahaha', '2024-07-22 10:59:53'),
(9, 2, 3, 7, 'Sejak nonton tayangan tiktoknya di yutub yang berpart part , saya jadi ingin sekali nonton versi film bioskopnya.\r\n\r\nBulan lalu ,saat thrillernya rilis , saya tonton dan bikin tambah pingin nonton film bioskopnya.\r\n\r\nSaya ingin nonton karena gemas dengan jalan cerita versi tiktok. Tokoh Rani dan Aris nampak super antagonis.\r\n\r\nAkhirnya Sabtu 22 Juni 2024 saya kesampaian nonton versi bioskopnya', '2024-07-22 11:00:20'),
(10, 2, 4, 6, 'Secara keseluruhan menurut saya film nya bagus, awal-awal kita akan di suguhkan dengan kisah cinta yang sangat sempurna, pendekatan antara tokoh utama nya begitu terasa. Sebuah kisah rumah tangga yang sangat perfect.\r\n\r\nSebelum Rani menyerang saya berfikir siapa sih yang tidak mau suami seperti Aris, yang pengertian, selalu mendukung cita-cita istri, humoris, sholeh, penyayang dll...\r\n\r\nTapi disamping itu, Aris adalah definisi lelaki brengsek sepenuhnya.. Saya sengaja nonton film ini bersama pacar untuk dijadikan warning agar jangan sampe begitu', '2024-07-22 11:00:55'),
(11, 2, 5, 7, 'ame bener ini film, jadi saya nonton karena penasaran. Kalo gak rame, mungkin gak bakal saya tonton, karena dari awal emg gak demen sama genre beginian. Apalagi saya belum berkeluarga. Tapi ternyata filmnya…….… Uhhhmmm…..\r\n\r\nYa oke oke aja. Wkwk\r\n\r\nMaksudnya, ya bagus, tapi gak bagus² amat. 7/10 aja lah rating dari saya. Ada yg bilang Lebih bagus dari Layangan Putus. Ya saya setuju2 aja kalau itu.\r\n\r\nPertama, ada beberapa adegan² dan karakter² yg memorable. Dan yg saya maksud dari memorable itu ya yg bikin saya ketawa itu, sama adegan yg panjang (bagian klimaks) itu juga sih. Kedua, akting para pemain tidak ada yg jelek, semua sudah sangat bagus, apresiasi buat semua pemain. Kemudian, untungnya juga filmnya tidak banyak ngikutin adegan² klise kyk di sinetron Ind**iar.', '2024-07-22 11:01:31'),
(12, 3, 1, 7, 'Sekawan Limo senafas dengan Agak Laen, mampu menciptakan cerita yang universal meski pun latar belakang kedaerahannya kental.', '2024-07-22 11:04:46'),
(13, 4, 1, 5, 'Kuyang (2024) satu lagi film yang tidak punya otak dan tidak berguna. Sampai kapan masyarakat Indonesia akan terus mempercayai ilmu hitam!! Saya pasti sudah banyak melihat film-film Indonesia yang tidak masuk akal seperti ini di Netflix. Tolong buatkan film horor yang masuk akal.\r\n\r\nSaya belum mengerti apa itu Kuyang? Yang saya suka di film ini adalah terbang dan membakar kepala tanpa badan yang terbang lebih cepat dari udara. Selain itu, hanya ada satu perahu untuk perjalanan masyarakat kota kecil yang juga terbakar dan hancur. Mengapa wanita jahat itu tidak menyakiti penduduk setempat? Belum ada klarifikasi lebih lanjut mengenai anak-anak yang tewas akibat banjir. Mereka adalah korban wanita jahat itu? Bagaimanapun, film ini bisa dihindari.', '2024-07-22 11:06:00'),
(14, 4, 2, 7, 'Ketika saya kebetulan menemukan film horor Indonesia tahun 2024 Kuyang: Sekutu Iblis yang Selalu Mengintai di Netflix, tentu saja saya tidak perlu dibujuk untuk duduk dan menontonnya mengingat kecintaan saya pada film horor dan sinema Asia.\r\n\r\nTentu saja, saya bahkan tidak tahu tentang film itu, karena saya belum pernah mendengarnya. Tapi itu tidak menjadi masalah, karena ini adalah film horor Asia yang belum pernah saya tonton. Yup, itulah betapa saya menikmati horor dan sinema Asia.\r\n\r\nPenulis Achmad Benbela dan Alim Sudio menyusun naskah dan jalan cerita yang cukup menyenangkan dan menghibur. Ceritanya diceritakan dengan baik, dan sutradara Yongki Ongestu pandai mengatur filmnya, menumpuk ketegangan dan perlahan-lahan membiarkan semakin banyak hal terungkap kepada penonton. Saya harus mengatakan bahwa saya benar-benar terhibur sepanjang 97 menit film tersebut diputar. Satu-satunya kekurangan dari Kuyang: Sekutu Iblis yang Selalu Mengintai adalah naskahnya yang mudah ditebak.\r\n\r\nMeskipun saya tidak mengenal aktor dan aktris dalam film tersebut, selain aktor Egy Fedly, menurut saya penampilan aktingnya bagus, dan mereka pasti memiliki pemain yang hebat. Para aktor dan aktrisnya benar-benar membawakan film tersebut dengan cukup baik.\r\n\r\nSesuatu yang membuat saya terkesan tentang Kuyang: Sekutu Iblis yang Selalu Mengintai adalah efek spesialnya. Efek spesialnya ternyata bagus dan tampak realistis, dan itu menambah banyak kesan keseluruhan film tersebut.\r\n\r\nJika Anda menyukai sinema horor Asia, maka Kuyang: Sekutu Iblis yang Selalu Mengintai adalah film yang layak untuk ditonton.\r\n\r\nRating saya untuk Kuyang: Sekutu Iblis yang Selalu Mengintai adalah tujuh dari sepuluh bintang.', '2024-07-22 11:07:28'),
(15, 4, 3, 7, 'Bukan \'menakutkan\', lebih seperti \'menarik\'. Ceritanya sedikit menggugah rasa penasaran saya, padahal banyak plot hole dan endingnya menggunakan formula yang terasa \'basi\'. Efek visualnya oke, lagipula ini teknologi 2024 (?). Namun sepertinya suasana horor \'tidak ada\'. Film ini terlalu mengandalkan efek suara untuk jumpscare. Aktingnya seperti drama sekolah. Misalnya, ketika seorang anak dalam bahaya, berdarah, dan terseret sesuatu ke langit-langit! Tidak ada rasa urgensi apapun (telapak tangan), sangat tidak meyakinkan. Ketika dermaga terbakar, orang-orang hanya berdiri saja, seolah-olah para figuran tidak diberitahu apa yang harus dilakukan. Rasanya para aktor dan aktris berusaha terlalu keras untuk \'berakting\' sehingga hasilnya menjadi tidak meyakinkan, padahal film yang bagus seharusnya membuat penontonnya lupa bahwa mereka sedang menonton sebuah film.', '2024-07-22 11:07:59'),
(16, 5, 1, 6, 'Digunakan yang pertama dan untuk mendapatkan jendela browser Anda juga akan memiliki yang pertama kali untuk yang baru dan lebih banyak informasi tentangnya terakhir diperbarui untuk digunakan untuk lokasi item ini untuk browser Anda untuk melakukan informasi berikut agar Anda dilindungi kata sandi dan untuk membuat kata sandi Anda dan informasi lebih lanjut untuk halaman ini agar dapat digunakan untuk melakukan Anda adalah teman atau pihak lain yang baru dan untuk membuat kata sandi Anda terlindungi dari nomor item ini ke informasi berikut tentang informasi berikut untuk informasi produk ini pada ini adalah informasi berikut tentang halaman ini masing-masing.', '2024-07-22 11:09:05'),
(17, 5, 2, 7, 'Meeh, satu lagi film yang melibatkan agama, dan apakah film ini berdasarkan kisah nyata atau sekedar sanggahan penulis sehingga membuat film ini terlihat sangat seram. Namun dalam film ini, meski melibatkan banyak hal yang berbau religi, namun film ini berhasil membuat saya tidak kecewa. Plot yang dihadirkan juga solid sehingga penonton tidak merasa bosan.\r\n\r\nPenonton dibuat resah saat film mengambil setting malam atau siang hari karena adanya jumpscare jumpscare. Namun efek suara yang dihadirkan malah membuat jumpscare menjadi ringan bahkan terlihat ngeri.\r\n\r\nNamun visual yang dihadirkan juga lumayan, tidak bagus tapi juga lumayan. Kali ini saya memberikan sedikit apresiasi kepada anggi umbara yang sering mendapat banyak kritikan dari saya. Secara keseluruhan film ini masih layak untuk ditonton dibandingkan film-film lain karya penulis ini.', '2024-07-22 11:09:40'),
(18, 6, 3, 5, 'Konflik dalam Pemukiman Setan bermula dari Alin dan kawan-kawannya yang merupakan seorang pencuri. Teuku Rifnu Wikana memerankan Urip Mahesworo, sosok misterius yang terlibat teror Alin. Meski muncul di pertengahan film, Teuku Rifnu mencuri perhatian dan memikat penonton. Jumpscare efektif karena skornya yang intens, menimbulkan keterkejutan atau rasa berdebar-debar di antara penonton. Ketegangan yang dialami Alin menggema di kalangan penonton yang merasa kesal dengan tindakannya. Penonton mungkin merasa terdorong untuk turun tangan dan membantu Alin mengatasi kutukan Sukma. Meski begitu, film ini tetap membuat saya bernapas lega karena endingnya.', '2024-07-22 11:10:38'),
(19, 6, 4, 7, 'Sarang Setan berasal dari pembuat Qodrat. Dari segi promosi, mereka sepertinya lebih menekankan unsur aksi dibandingkan horor dan fantasi. Mungkin dalam upaya agar produksi ini membedakan dirinya dari produksi horor murni. Meskipun ini merupakan tambahan yang disambut baik. Menurut saya, hal ini tidak cukup lazim untuk membuat film menjadi lebih menarik. Sebenarnya, saya ingin berargumentasi bahwa khususnya dalam kasus ini, hal tersebut bertentangan dengan filmnya.\r\n\r\nAku jadi berat, Don\'t Breathe bertemu dengan getaran Evil Dead. Saya seperti, hebat. Alih-alih membuat orang buta tapi tidak begitu polos dirampok, pencuri justru mengincar rumah yang diyakini kosong. Tentu saja tidak demikian. Mereka dihadapkan pada kekuatan yang sulit mereka persiapkan. Orang bisa berdebat apakah alasan mereka mencuri itu bagus. Jelas terlihat bahwa semua pencuri sangat putus asa. Dan untuk menunjukkan itikad baik, mereka berencana untuk tidak serakah dan hanya mencuri apa yang mereka butuhkan. Meskipun logika mereka salah, sampai taraf tertentu saya dapat memahami dari mana mereka berasal. Masalahnya adalah hukum dan keadilan tidak peduli dengan logika seperti itu dan akan menghukum Anda seolah-olah Anda berniat mencuri segalanya, lalu mengapa tidak mencuri semuanya? Untungnya bagi mereka, mereka tidak harus berurusan dengan hukum. Ya, mereka malah harus melawan iblis, yang jelas lebih buruk.\r\n\r\nNah, ini membuat saya terkesan bersimpati pada karakter utamanya. Saya pada awalnya ya. Kemudian Anda melihat karakter-karakter ini membuat kesalahan demi kesalahan. Saya berteriak ke layar karena bertindak begitu bodoh. Namun anehnya, mereka tidak pernah mendengarkan. Ada salah satu kucing keren, Urip, di film yang mencuri perhatian. Saya sangat senang dia ada di dalamnya, jika tidak, saya mungkin tidak akan mampu menahan kejenakaan karakter lain. Ia diperankan oleh T. Rifnu Wikana. Dia memberikan pengertian pada mereka. Jika Anda bertanya kepada saya, mereka seharusnya membuang yang lain dan menjadikannya sebagai petunjuk.\r\n\r\nApa yang menurut saya sedikit bermasalah adalah kenyataan bahwa mereka tidak condong ke elemen horor seperti yang saya inginkan. Alih-alih meningkatkan ketegangan dan ketakutan, mereka justru malah menumpahkan darah dan darah kental. Dalam beberapa adegan, ini jelas efektif. Tapi film ini meminta intensitas tertentu. Adinda Thomas sebagai Sukma tentu saja berusaha sekuat tenaga untuk tampil sebagai orang mati yang menakutkan. Kudos padanya dalam hal itu. Andai saja mereka mendukungnya dengan menjadikannya lebih berbahaya dan menakutkan. Dalam beberapa adegan mereka begitu dekat. Dorongan Maudy Effrosina sebagai Alin menjadi petarung iblis super duper patut dipertanyakan. Kalau bukan karena Urip dia pasti sudah mati. Terlepas dari satu tindakan yang muncul begitu saja, tidak ada apa pun dalam dirinya yang menjadikannya seorang bos perempuan. Seandainya dia meningkatkan permainannya karena apa yang harus dia lalui dan secara organik telah mengembangkan keterampilan melawan iblisnya, maka ya, tentu saja saya akan menyambutnya.\r\n\r\nKemungkinan besar, sekuelnya direncanakan. Dan saya bersedia memeriksanya selama mereka memperbaiki bagian ini. Untuk saat ini, itu cukup layak. Rasanya tidak akan membuang-buang waktu.', '2024-07-22 11:11:10'),
(20, 7, 4, 1, 'Ini omong kosong di puncaknya, film tentang penipu yang selingkuh dengan suami temannya, ketika para istri mengetahui bahwa mereka membawa semua penduduk desa untuk membunuh penipu, 20 tahun setelah penipu itu mati, tiba-tiba dia merasa ingin membalas dendam pada teman-temannya. Beneran cewek? Setelah 20 tahun? Apa yang kamu lakukan selama 20 tahun di neraka? Menghisap pantat setan sehingga dia mengeluarkanmu dari neraka?? Saya jarang menonton film Indonesia tapi ini no #1 di peringkat netflix untuk film di Indonesia, setelah menonton film ini saya khusus membuat akun IMDB hanya untuk menghina film ini, bagus sekali mesin cuci mayat.\r\n\r\nHantu di film ini tidak terlalu menakutkan, mereka hanya menggunakan terlalu banyak bedak dan maskara. Dan tukang lemari mungkin terlalu banyak menonton anime hampir semua hantu hanya menggunakan byakugan dari naruto, saya sarankan jika Anda malas silakan melempar sharingan agar mata hantu lebih bervariasi, hantu itu kerasukan temannya dan bermata merah tidak\' Tidak dihitung karena dia hanya meniru temannya dan bukan hantu penipu itu sendiri.\r\n\r\nMasih banyak lagi hal yang ingin saya tambahkan, namun saat ini semua yang saya tulis hanya akan menjadi lelucon saja. Adios teman-teman.', '2024-07-22 11:12:59'),
(21, 7, 3, 10, '### Ulasan Film: *Pencuci Mayat*\r\n\r\n*Corpse Washer* adalah film yang menyelami sudut paling gelap dari ketakutan manusia dan ketakutan supernatural, sebuah film yang pasti akan membuat penonton terpaku pada tempat duduk mereka. Disutradarai oleh pembuat film yang penuh teka-teki dan visioner, Sophia Delacroix, film ini unggul dalam menghadirkan suasana yang begitu tegang hingga terasa seperti entitas yang hidup dan bernapas. Dari adegan pembuka, Delacroix memberikan nada firasat yang mencengkeram Anda dan tidak melepaskannya hingga kredit akhir bergulir. Plotnya berpusat di sekitar sebuah desa kecil yang terpencil di mana ritual kuno memandikan orang mati dilakukan oleh beberapa orang terpilih, sebuah tugas suci yang telah diturunkan dari generasi ke generasi. Sang protagonis, Lena, diperankan dengan intensitas yang menghantui oleh Eliza Taylor, ditarik kembali ke rumah leluhurnya setelah kematian mendadak ibunya, yang merupakan orang terakhir yang mencuci mayat di desa tersebut.', '2024-07-22 11:13:42'),
(22, 7, 2, 5, 'Karakter kikuk, aktor buruk, alur cerita aneh & akhir menyedihkan. Film ini penuh dengan jumpscare; lebih dari yang dibutuhkan, hantu hadir sepanjang film. Komposisi hantunya berlebihan. Filmnya terlalu panjang. Semua cerita bisa ditebak. Seorang janda muda di desa merayu beberapa pria dan istri mereka menjadi tidak senonoh terhadapnya. Mereka secara brutal menyiksanya sampai mati. Putrinya menyaksikan kematian ibunya tetapi para wanita menutup telinga. Setelah itu sang putri melontarkan kutukan pada pelaku utama. 1 Pada pukul 1, wanita pembunuh terus sekarat & pahlawan wanita memandikan mereka dan mengkonfirmasi temuan kutukan dan mengumumkan nama wanita tersebut. Ini adalah titik di mana film runtuh. Akhir ceritanya menyedihkan. Namun; secara keseluruhan menyenangkan untuk ditonton.', '2024-07-22 11:14:06'),
(23, 7, 1, 5, 'Plotnya mudah ditebak dan elemen klisenya. Meskipun kurang orisinalitas, ia juga dilengkapi dengan jumpscare yang khas, cobalah untuk menciptakan suasana yang menakutkan. Pertunjukannya lumayan, tapi dialognya terasa tidak natural. Terlepas dari kekurangannya, film ini memberikan hiburan horor yang lumayan bagi mereka yang mencari sensasi langsung.\r\n\r\nSinematografinya meningkatkan suasana yang tidak menyenangkan, meskipun karakter dan dialognya berada dalam wilayah yang familiar. Secara keseluruhan, ini adalah pilihan yang oke untuk menonton film malam di rumah.\r\n\r\nJika Anda mencari alur cerita yang rumit atau unik, maka ini bukanlah film yang Anda cari. Kurangnya ketegangan cukup mengecewakan.', '2024-07-22 11:14:38'),
(24, 8, 1, 5, 'Saya penggemar gagasan membuat film tidak menggunakan dialog. (Karakter hanya kadang-kadang menyebutkan nama karakter lain, jadi setidaknya aktor utama lebih mungkin mendapat kompensasi yang adil sebagai bagian yang berbicara.) Saya tidak keberatan dengan darah palsu yang campy selama ada ketegangan dan alur cerita yang bagus. Sinematografi jelas memiliki momen bagus untuk menciptakan ketegangan. Hanya dua kali dalam film itu saya menemukan diri saya berada dalam momen yang tampak menggelikan dan membuat saya keluar dari keterpurukan. Salah satunya adalah spoof The Shinning dari adegan Here\'s Johnny yang dimainkan dengan sangat baik, terutama oleh aktris cilik yang menggantikan Duvall, namun bahkan dalam bentuk yang disingkat, adegan tersebut terlalu panjang untuk tidak dianggap sebagai sebuah adegan. agak membosankan dan tidak pada tempatnya. Momen lainnya adalah ketika karakter utama kita berhenti mencuri kentang goreng yang ditinggalkan oleh tokoh antagonis dan cemberut. Saya dapat melihat bagaimana mereka bermaksud menjadikan momen ini sebagai momen untuk menunjukkan rasa kemanusiaan dan membangkitkan rasa kasihan terhadap anak tersebut, namun hal tersebut malah dianggap sebagai momen kesembronoan yang tidak pada tempatnya. Namun saya bisa memaafkan hal-hal itu. Hal yang benar-benar membuat saya kesal adalah stereotip yang digunakan untuk menggambarkan tipe dasar orang jahat Pemain game yang suka merokok dan minum bir, memainkan game MMO yang penuh kekerasan hingga larut malam, memiliki rambut panjang yang tidak terawat dan topi baseball hitam atau hoody dengan jaket terbuka dan jeans robek, menyantap mie instan dan makanan cepat saji, mengabaikan rumah yang tadinya indah. dianggap remeh dan benar-benar dipenuhi kecoak. Dan jangan lupa bahwa ini seharusnya menjadi predator anak-anak. Itu hanya memenuhi setiap tanda centang untuk stereotip buruk. Ketika kami mendapatkan penjahat kedua dalam cerita, segalanya mulai menegangkan.', '2024-07-22 11:20:16'),
(25, 8, 2, 5, 'Bukan spoiler kalau film ini tidak mengandung dialog apa pun -- atau mungkin memang ada, tapi dialog yang diberikan oleh Netflix sendiri sejak awal. Tidak mengetahui hal ini akan menambah ketegangan pada film ini, sesuatu yang sayangnya kurang dimiliki oleh film televisi buatan Indonesia ini.\r\n\r\nTidak ada klise yang tidak tersentuh di sini. Adegan berulang berlimpah (pahlawan wanita bersembunyi di bawah tempat tidur, di balik pintu, di lemari, dan ini berulang kali). Tidak ada kejutan yang mengejutkan (oops, apakah itu spoiler lain?). Tidak ada alur cerita rumit yang harus diurai. Tidak ada upaya yang dilakukan untuk memberikan kepribadian pada penangkap dan pasangannya; rumah dengan interiornya yang hambar bahkan tidak terlihat seperti milik mereka.\r\n\r\nKesimpulannya, meskipun diberi rating, ini pada dasarnya adalah film anak-anak, baik dalam arti kata, dan juga kekanak-kanakan. Akan lebih efektif bila dipersingkat menjadi, katakanlah, dua puluh menit.', '2024-07-22 11:20:39'),
(26, 8, 3, 5, 'Karena tokoh utamanya adalah seorang gadis kecil berusia hampir 10 tahun yang berkembang menjadi tokoh utama dalam cerita, mengakali dua penjahat dewasa, ini terasa seperti film yang ditujukan untuk anak-anak. Namun kejadiannya cukup keras, dengan penikaman, penembakan, kapak, dan beberapa lompatan menakutkan yang efektif; jadi bukan barang anak-anak, menurutku.\r\n\r\nIni pada dasarnya adalah cerita satu dimensi: dua anak diculik secara paksa dan dibawa ke sebuah pondok terpencil. Masih belum jelas alasannya: untuk tebusan? Pelecehan anak? Perdagangan manusia? Sayangnya mereka tidak memberikan sedikit pun latar belakang kepada penjahat dan istrinya. Gadis kecil itu mampu membebaskan dirinya dan kemudian permainan kucing-dan-tikus dimulai antara penjahat dan gadis itu. Kita tak henti-hentinya melihat mereka berlarian satu sama lain di dalam rumah, bersembunyi, ditemukan, berlari lagi, bersembunyi lagi, dan seterusnya, dan seterusnya. Tidak ada liku-liku yang serius, jadi tak lama kemudian hal itu mulai menjadi berulang dan hampir membosankan.\r\n\r\nTanpa alasan yang jelas (tetapi dengan berani diumumkan di bagian kredit, jadi pasti ada motif mendalam di baliknya!), film ini tidak memiliki dialog sama sekali. Sebagian besar karena tidak ada yang berbicara, mereka hanya berlarian dan terengah-engah. Tapi suatu saat gadis itu menggunakan interkom mobil polisi untuk meminta pertolongan, kita melihat bibirnya bergerak tapi kita tidak mendengarnya. Hal ini membuat idak ada dialog ini tampak lebih seperti keinginan sutradara yang sok.\r\n\r\nOmong-omong, anak-anak memainkan peran (diam) mereka dengan cukup meyakinkan, terutama gadis kecil yang membawa keseluruhan film di bahu mungilnya. Dan skor musiknya bagus. Tapi beberapa aktor cilik yang mengagumkan, beberapa jumpscare yang bagus, dan skor yang bagus tidak cukup untuk membuat film yang bagus.', '2024-07-22 11:21:14'),
(27, 8, 4, 1, 'Ya Tuhan, saya tidak pernah menulis ulasan tapi ini sangat buruk sehingga saya harus membuat akun.\r\n\r\nSaya belum pernah melihat begitu banyak keputusan yang sangat bodoh, bahkan untuk seorang anak kecil sekalipun.\r\n\r\nFilm ini bisa selesai dalam 10 menit jika dia berlari dan mendapat bantuan segera setelah dia melarikan diri daripada kembali ke dalam. Lagi. Dan lagi. Dan lagi.\r\n\r\nLihat orang jahat itu bahkan belum tidur di sofa? Ayo ambil kuncinya! Berhasil mendapatkannya secara diam-diam? Bagus, mari kita duduk di sini dan menatap mereka sampai dia bangun dan menangkapku!\r\n\r\nMelakukan serangan pisau dengannya tetapi entah bagaimana berhasil menikamnya? Saatnya menatapnya dan melihatnya mati. Mengapa harus mencari tempat aman ketika saya bisa melihat cahaya meninggalkan matanya?\r\n\r\nBerhasil mendapatkan ponselnya? Ada tombol untuk menelepon darurat tanpa PIN? NAH, jangan gunakan itu. (Saya rasa hal ini dianggap wajar karena dia masih anak-anak, tapi agak sulit dipercaya dia tidak tahu atau tidak bisa memahami hal ini.)\r\n\r\nDiberikan 15 kesempatan untuk kabur? Tidak menggunakannya.\r\n\r\nLihat wanita nakal dengan kapak mendekati polisi? Tidak, jangan peringatkan dia, tatap saja dengan tatapan kosong sampai dia terbunuh.\r\n\r\nOrang jahat tersingkir? Jangan lari, ayo dekati mereka dan tatap mereka sampai mereka bangun dan menangkapku.\r\n\r\nAkhirnya menangkap temanku dan kabur keluar? Dan tokoh antagonis ada di belakang kita? TUNGGU. Kami membutuhkan sepatu. Mobil polisi di sana? Tidak, mari kita naik sepeda yang membawa kita sejauh 5 kaki, terjatuh, lalu pergi ke mobil polisi.\r\n\r\nSetelah mobil mengalami kecelakaan, tentunya hal cerdas yang harus dilakukan adalah berlari kembali ke rumah untuk mengambil sepeda yang rusak tersebut! Perbaiki sepedanya, gunakan untuk menjauh sebentar dari rumah, lalu jatuhkan lagi untuk berjalan kaki lagi. Dalam garis lurus. Dimana terdapat jalur yang bagus untuk wanita tersebut mengemudikan truk. Harus sopan!\r\n\r\nPilihan antara lapangan terbuka atau hutan? Mari kita ambil lapangan terbuka, tentu saja!\r\n\r\nLihat kecelakaan mobil wanita itu? Mari kita berjalan kembali hanya untuk memeriksanya.\r\n\r\nLalu entah bagaimana secara ajaib ada kaki yang tersangkut di... Batu? Bahkan tidak yakin bagaimana dia mengaturnya.\r\n\r\nLalu kita punya wanita jahat itu.\r\n\r\nApakah anak-anak terjebak di dalam mobil sambil memegang kapak? Saya harus mendekati situasi ini dengan hati-hati dan perlahan-lahan memutari mobil dan menatap setiap anak dengan pandangan mengancam sementara mereka berhasil memanggil bantuan dari radio.\r\n\r\nMasuk ke dalam mobil yang mulai berputar mundur? MASIH DENGAN KAPAK. Nah, jangan GUNAKAN kapak, mari kita coba ambil dengan tanganku.\r\n\r\nDi lapangan terbuka di mana anak-anak hampir tidak berlari di depan saya, SAAT saya MENGEMUDI TRUK, saya akan mengemudi cukup lambat sehingga saya tidak dapat mengejar mereka. Lalu entah bagaimana membalikkan mobilku dengan agresif beberapa kali meskipun kecepatanku lebih rendah dibandingkan kecepatan lari anak yang terluka.\r\n\r\nHanya. Jangan. Jam tangan. Ini. Saya tipe orang yang terkadang menikmati film horor bodoh yang bagus, tapi ini level berikutnya.', '2024-07-22 11:21:45'),
(28, 8, 5, 1, 'Film ini mungkin saja pendek. Begitu gadis itu melarikan diri, dia bisa saja mencari bantuan. Ceritanya memiliki banyak alur cerita... seperti ketika mereka melarikan diri dari rumah tetapi kembali hanya untuk mengambil sepatu, meluangkan waktu untuk memakainya dan membiarkan penjahat mengejar mereka. Juga begitu banyak jalan keluar... kita tidak mengetahui motif penjahat atau mengapa polisi datang ke rumah mereka. Protagonis utama juga membuat banyak keputusan konyol dan kapan pun dia membuat kemajuan, langkah selanjutnya juga akan membawa mereka ke titik terang. Sepertinya dia melakukannya dengan sengaja agar gagal – mungkin dialah monsternya pada akhirnya.', '2024-07-22 11:22:09'),
(29, 9, 1, 9, 'Ketika saya masuk untuk menonton film ini, saya tidak memiliki ekspektasi yang besar. Saya berpikir,h mungkin ini seperti kebanyakan film komedi yang leluconnya ada dalam 1-3 adegan. Tapi aku salah, dari semua film komedi yang aku tonton, aku tidak pernah tertawa sekeras ini selama ini. Setiap adegan disampaikan dengan lelucon yang sangat bagus yang membuat seluruh bioskop tertawa terus-menerus. Mereka melontarkan lelucon stereotip batak dengan aksen batak dengan keras hahaha. Film ini pasti dapat ditonton ulang. Walaupun film ini mungkin sulit bagi kamu yang nonton dub atau sub karena sebagian besar lawakannya disampaikan dalam bahasa Indonesia tapi nggak apa-apa, ajak saja temanmu yang orang Indonesia untuk nonton bareng haha.', '2024-07-22 11:22:51'),
(30, 9, 2, 8, 'Menurut saya film komedi Indonesia penuh dengan stand-up talenta dengan lelucon satu kalimat yang tersebar dalam latar cerita utama yang sederhana dan bagus. Hal ini menyebabkan serangkaian film sukses di box office tetapi tidak ada substansi yang dapat membedakan satu film dari film lainnya. Agak Laen membuktikan bahwa formulanya bisa segar bila dihadirkan dengan latar cerita yang sungguh menakjubkan dan nuansa realisme.\r\n\r\nFilm ini memiliki pengaturan komedi situasi yang sempurna. Atraksi rumah hantu menjadi viral setelah ada orang sungguhan meninggal di sana. Itu penuh dengan adegan-adegan hebat dengan pengaturan waktu komedi yang keren, mereka tahu cara beralih antara adegan drama dan lucu dengan baik. Saya rasa keempat karakter tersebut terlalu banyak karena ciri-ciri mereka terlihat serupa, sehingga menjadi kabur untuk mengingat siapa itu siapa. Plotnya mencoba memberi nuansa dengan lebih banyak chemistry dan masalah pribadi, dan berhasil!\r\n\r\nKlimaksnya adalah salah satu yang terbaik yang pernah saya lihat. Bersikap realistis dan tidak mengabaikan logika dasar meski bergenre komedi. Saya masih sangat kecewa dengan cara mereka terus membuat iklan yang blak-blakan sepanjang film, yang menurut saya bisa lebih baik. Meski begitu, menonton Agak Laen memberi saya harapan bahwa film komedi Indonesia punya masa depan cerah', '2024-07-22 11:23:17'),
(31, 9, 3, 8, 'Aku bahkan tidak berniat untuk menonton film ini dari awal, aku pernah melihat trailernya namun baru setelah itu teman-temanku mengajakku untuk menontonnya dan aku harus mengatakan bahwa pada akhirnya, aku senang telah menontonnya.\r\n\r\nSuka banget sama masing-masing karakternya (Bene, Jegel, Boris, dan Oki) yang punya latar belakang dan motivasinya masing-masing, meski berbeda perjuangannya tetap sama, yaitu perjuangan finansial. Ini adalah jenis perjuangan yang paling mudah untuk dihadapi. Risiko yang bersedia mereka ambil dan keputusan bodoh yang mereka ambil adalah hal-hal yang pada akhirnya menentukan alur cerita.\r\n\r\nSingkatnya, filmnya cukup lucu, maksud saya mereka semua komedian, jadi saya mengharapkannya. Saya akan merekomendasikannya.', '2024-07-22 11:23:41'),
(32, 9, 4, 8, 'Film ini memang mempunyai tone tersendiri, kondisinya berhubungan dengan situasi kehidupan sehari-hari. Semua pemain dan juga sutradaranya adalah Stand up Comedian, yang biasanya bisa membuat Comedy di Situasi Apapun\r\n\r\nMeski begitu, Nada Batak sangat ditonjolkan dalam komedi ini. Namun sekali lagi, film ini memiliki Lelucon Asli dan Segar tersendiri yang akan menghibur dengan tema tersendiri.\r\n\r\nSutradara Agak Laen Ernest Prakarsa juga merupakan Stand up Comedian Unggulan, dengan seluruh pemerannya juga merupakan stand up comedian. Dan film ini memberikan contoh bagaimana mereka bisa berinteraksi satu sama lain dengan lancar dan juga lucu.\r\n\r\nKerja Hebat untuk Penonton Film Indonesia, dan juga pembuat Box office.', '2024-07-22 11:24:02'),
(33, 9, 5, 9, 'Dengan judul itu memang menyampaikan hal itu .. hal-hal aneh dengan cara yang lucu. Dari awal filmnya mungkin orang akan mengira ini adalah film komedi slapstick biasa dari Indonesia yang sudah menjadi norma selama bertahun-tahun atau puluhan tahun jika Anda mau.\r\n\r\nKemudian kecepatan film mulai meningkat. Satu hal mengarah ke hal lainnya. Dan saat itulah film tersebut layak untuk ditonton hingga akhir.\r\n\r\nPatut disebutkan juga bahwa ini adalah salah satu film yang Anda ingin terus mendukung orang-orang jahat. Pengisahan cerita dilakukan dengan cara yang tidak akan membuat Anda bosan.\r\n\r\nDan ya, seiring berjalannya waktu, cerita akan berkembang di sekitar mereka dan itulah pilar dari semuanya. Ya, hidup itu sulit dan tidak ada yang mudah, tetapi cara menjalani hidup benar-benar berbeda.', '2024-07-22 11:24:25'),
(34, 10, 2, 6, 'Joko Anwar dikenal membuat film-film dengan standar yang menonjol seperti karakter yang hebat, premis yang menarik untuk diikuti, dialog yang memprovokasi, dan banyak adegan berdarah di sana-sini. Grave Torture memeriksa semua item, tapi sayangnya, ia juga memeriksa ciri khas Anwar yang terkenal: babak ketiga yang lemah.\r\n\r\nAnwar selalu menjadi pendongeng yang baik. Film ini tidak terkecuali. Ada misteri yang menggelegak di setiap sudutnya, meminta saya untuk menebak-nebak di setiap adegannya, dibekali dengan karakter-karakter yang jenaka, nyaris absurd, membuat saya tetap tenang dengan aspek teknis yang luar biasa, terutama desain suaranya. Kemudian, babak ketiga tiba.\r\n\r\nIni mengingatkan saya pada semua karya horor sebelumnya yang alur ceritanya menjadi kacau dan kabur. Saya tidak tahu caranya, tapi rasanya sangat eksploitatif. Ceritanya tidak banyak, hanya serangkaian adegan menarik penonton yang menyamar sebagai klimaks. Bagaimana hal itu membenarkan semua penumpukan? Bagaimana hal itu akan menjawab semua pertanyaan? Pertanyaan-pertanyaan itu membuatku tetap diam sampai tiba-tiba, pertanyaan itu berakhir.\r\n\r\nSaya sadar Anwar tidak bertanggung jawab membuat film yang bisa saya pahami sepenuhnya. Mungkin saya tidak cukup pintar untuk itu. Mungkin itu trik untuk mengantisipasi kemungkinan lanjutannya (kalau ada). Atau mungkin ini saatnya saya menerima bahwa gaya Anwar tidak akan pernah mengarah ke arah yang saya sukai. Tapi, menurut saya sebagian besar klimaksnya adalah jalan keluar yang mudah untuk pengembangan plot yang begitu menguntungkan yang ia buat.\r\n\r\nKemudian lagi, klimaksnya tetap ada di kepala saya selama dua hari. Hal ini berdampak besar.', '2024-07-22 11:25:07'),
(35, 10, 3, 6, 'Orang normal akan berbuat baik, berbuat baik satu sama lain dan tidak berbuat dosa untuk menghindari penyiksaan berat tapi di film ini, mereka akan melakukan hal-hal ini: 1. Membunuh banyak orang tak bersalah yang menunggu untuk mendapatkan diskon donat (Aku penasaran apakah sutradaranya benci DUNKIN) 2. Ustadzah membekali donatur pedofilia kaya dengan anak santri sambil berdakwah tentang penyiksaan berat 3. Membunuh perawat pezina yang sudah bertanya bagaimana cara bertaubat atas dosanya 4. Massa turun ke jalan untuk saling membunuh atau orang yang tidak bersalah\r\n\r\nSaya hanya berharap 1,4 juta orang yang telah menonton film ini akan menganggapnya hanya sebagai film horor dan tidak lebih.', '2024-07-22 11:25:29'),
(36, 10, 4, 8, 'Mungkin ini bukan karya terbaik yang pernah dibuat oleh Joko seperti yang disebutkan beberapa orang, namun sejauh ini ini adalah karya yang paling menyenangkan bagi saya. Kecepatannya bagus, tidak terlalu cepat, tidak terlalu lambat. Ceritanya juga cukup bisa dimengerti, setidaknya 80%-nya tanpa bantuan forum dan diskusi. Terbuka untuk interpretasi yang berbeda? Yap, bukan Joko kalau bukan. Lucunya, film ini bagi saya tidak terasa religius (dari satu agama tertentu) jika dipikir-pikir, karena film ini memiliki pesan universal tentang manusia yang menghadapi kematian saat mereka terbaring sekarat, bukan tentang orang yang menemukan keluar satu agama tertentu yang benar, atau dengan kata lain: Lebih bersifat psikologis daripada agama, lebih manusiawi daripada supranatural, sebuah perjalanan spiritual dan refleksi tentang akhir yang akan kita hadapi suatu hari nanti, bahkan bagi mereka yang tidak percaya.', '2024-07-22 11:26:12'),
(37, 10, 5, 5, 'Film pendek Grave Torture memikat penonton dengan premisnya yang menarik. Namun eksekusinya tersendat karena plot yang terburu-buru dan kesimpulan yang kurang memuaskan. Adaptasi panjang fitur berikutnya berjanji untuk mengatasi kekurangan ini. Tujuannya adalah untuk membangun hubungan karakter yang lebih dalam, memberikan landasan narasi yang lebih kredibel, dan secara signifikan memperluas inti penyiksaan dari judul tersebut.\r\n\r\nMeskipun film fitur memberikan beberapa perbaikan, sebagian besar perbaikan tersebut masih dangkal. Urutan penyiksaan, meskipun lebih intens, terbatas pada klimaks film. Eksplorasi lebih menyeluruh atas elemen tematik ini di sepanjang narasi akan menjadi tambahan yang baik.', '2024-07-22 11:26:52');

--
-- Triggers `reviews`
--
DELIMITER $$
CREATE TRIGGER `after_delete_reviews` AFTER DELETE ON `reviews` FOR EACH ROW BEGIN 
    INSERT INTO reviews_log (action_type, review_id, movie_id, user_id, rating, comment, review_date) 
    VALUES ('AFTER DELETE', OLD.review_id, OLD.movie_id, 
OLD.user_id, OLD.rating, OLD.comment, OLD.review_date); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_reviews` AFTER INSERT ON `reviews` FOR EACH ROW BEGIN 
    INSERT INTO reviews_log (action_type, review_id, movie_id, user_id, rating, comment, review_date) 
    VALUES ('AFTER INSERT', NEW.review_id, NEW.movie_id, 
NEW.user_id, NEW.rating, NEW.comment, NEW.review_date); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_reviews` AFTER UPDATE ON `reviews` FOR EACH ROW BEGIN 
    INSERT INTO reviews_log (action_type, review_id, movie_id, user_id, rating, comment, review_date) 
    VALUES ('AFTER UPDATE', NEW.review_id, NEW.movie_id, 
NEW.user_id, NEW.rating, NEW.comment, NEW.review_date); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_reviews` BEFORE DELETE ON `reviews` FOR EACH ROW BEGIN 
    INSERT INTO reviews_log (action_type, review_id, movie_id, user_id, rating, comment, review_date) 
    VALUES ('BEFORE DELETE', OLD.review_id, OLD.movie_id, 
OLD.user_id, OLD.rating, OLD.comment, OLD.review_date); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_reviews` BEFORE INSERT ON `reviews` FOR EACH ROW BEGIN 
    INSERT INTO reviews_log (action_type, review_id, movie_id, user_id, rating, comment, review_date) 
    VALUES ('BEFORE INSERT', NEW.review_id, NEW.movie_id, 
NEW.user_id, NEW.rating, NEW.comment, NEW.review_date); 
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_reviews` BEFORE UPDATE ON `reviews` FOR EACH ROW BEGIN 
    INSERT INTO reviews_log (action_type, review_id, movie_id, user_id, rating, comment, review_date) 
    VALUES ('BEFORE UPDATE', OLD.review_id, OLD.movie_id, 
OLD.user_id, OLD.rating, OLD.comment, OLD.review_date); 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reviews_log`
--

CREATE TABLE `reviews_log` (
  `log_id` int(11) NOT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `review_id` int(11) DEFAULT NULL,
  `movie_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `review_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `log_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `created_at`) VALUES
(1, 'Rifqi Dani', 'rifqidani@example.com', '2024-07-22 10:46:31'),
(2, 'Nasyid Yunitian', 'mnasyid@example.com', '2024-07-22 10:46:49'),
(3, 'Aisha', 'aisha123@example.com', '2024-07-22 10:47:05'),
(4, 'Sofyan', 'sofyan321@example.com', '2024-07-22 10:47:21'),
(5, 'Nery Vandella', 'vandela@example.com', '2024-07-22 10:47:36');

-- --------------------------------------------------------

--
-- Table structure for table `user_movie_ratings`
--

CREATE TABLE `user_movie_ratings` (
  `movie_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `director_name`
--
DROP TABLE IF EXISTS `director_name`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `director_name`  AS SELECT `directors`.`director_id` AS `director_id`, `directors`.`name` AS `name` FROM `directors` ;

-- --------------------------------------------------------

--
-- Structure for view `horror_movies`
--
DROP TABLE IF EXISTS `horror_movies`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horror_movies`  AS SELECT `movies`.`movie_id` AS `movie_id`, `movies`.`title` AS `title`, `movies`.`director_id` AS `director_id`, `movies`.`release_year` AS `release_year`, `movies`.`genre_id` AS `genre_id`, `movies`.`synopsis` AS `synopsis` FROM `movies` WHERE `movies`.`genre_id` = (select `genres`.`genre_id` from `genres` where `genres`.`genre_name` = 'Horror') ;

-- --------------------------------------------------------

--
-- Structure for view `horror_movies_title`
--
DROP TABLE IF EXISTS `horror_movies_title`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horror_movies_title`  AS SELECT `horror_movies`.`movie_id` AS `movie_id`, `horror_movies`.`title` AS `title` FROM `horror_movies`WITH CASCADED CHECK OPTION  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `directors`
--
ALTER TABLE `directors`
  ADD PRIMARY KEY (`director_id`);

--
-- Indexes for table `genres`
--
ALTER TABLE `genres`
  ADD PRIMARY KEY (`genre_id`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`movie_id`),
  ADD KEY `genre_id` (`genre_id`),
  ADD KEY `director_id` (`director_id`);

--
-- Indexes for table `movie_genres`
--
ALTER TABLE `movie_genres`
  ADD PRIMARY KEY (`movie_id`,`genre_id`),
  ADD KEY `genre_id` (`genre_id`),
  ADD KEY `idx_movie_genre` (`movie_id`,`genre_id`);

--
-- Indexes for table `profiles`
--
ALTER TABLE `profiles`
  ADD PRIMARY KEY (`profile_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `movie_id` (`movie_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_user_movie` (`user_id`,`movie_id`);

--
-- Indexes for table `reviews_log`
--
ALTER TABLE `reviews_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `user_movie_ratings`
--
ALTER TABLE `user_movie_ratings`
  ADD PRIMARY KEY (`movie_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `directors`
--
ALTER TABLE `directors`
  MODIFY `director_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `genres`
--
ALTER TABLE `genres`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `movies`
--
ALTER TABLE `movies`
  MODIFY `movie_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `profiles`
--
ALTER TABLE `profiles`
  MODIFY `profile_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `reviews_log`
--
ALTER TABLE `reviews_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `movies`
--
ALTER TABLE `movies`
  ADD CONSTRAINT `movies_ibfk_1` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`),
  ADD CONSTRAINT `movies_ibfk_2` FOREIGN KEY (`director_id`) REFERENCES `directors` (`director_id`);

--
-- Constraints for table `movie_genres`
--
ALTER TABLE `movie_genres`
  ADD CONSTRAINT `movie_genres_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`),
  ADD CONSTRAINT `movie_genres_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`);

--
-- Constraints for table `profiles`
--
ALTER TABLE `profiles`
  ADD CONSTRAINT `fk_profiles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `user_movie_ratings`
--
ALTER TABLE `user_movie_ratings`
  ADD CONSTRAINT `user_movie_ratings_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`),
  ADD CONSTRAINT `user_movie_ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
