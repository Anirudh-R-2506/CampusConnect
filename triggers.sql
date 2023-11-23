DELIMITER //

CREATE TRIGGER before_insert_post
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.title) > 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Title must not exceed 50 characters';
    END IF;

    IF NEW.location IS NOT NULL AND CHAR_LENGTH(NEW.location) > 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Location must not exceed 60 characters';
    END IF;

    IF CHAR_LENGTH(NEW.body) > 1000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Body must not exceed 1000 characters';
    END IF;
END;

CREATE TRIGGER before_insert_or_update_validate
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.name) > 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name must not exceed 50 characters';
    END IF;

    IF CHAR_LENGTH(NEW.username) > 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username must not exceed 60 characters';
    END IF;

    IF NEW.username IS NOT NULL AND EXISTS (SELECT 1 FROM users WHERE username = NEW.username AND id != NEW.id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username must be unique';
    END IF;

    IF CHAR_LENGTH(NEW.email) > 225 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email must not exceed 225 characters';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE email = NEW.email AND id != NEW.id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email must be unique';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM roles WHERE id = NEW.role_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid role_id. Role does not exist.';
    END IF;

    IF NEW.password IS NOT NULL AND CHAR_LENGTH(NEW.password) > 225 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password must not exceed 225 characters';
    END IF;
END;

CREATE TRIGGER before_insert_comment
BEFORE INSERT ON comments
FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.comment) > 5000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Comment must not exceed 5000 characters';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM posts WHERE id = NEW.post_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid post_id. Post does not exist.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid user_id. User does not exist.';
    END IF;
END;

CREATE TRIGGER before_insert_like
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM likes WHERE post_id = NEW.post_id AND user_id = NEW.user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate like. User has already liked this post.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM posts WHERE id = NEW.post_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid post_id. Post does not exist.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM users WHERE id = NEW.user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid user_id. User does not exist.';
    END IF;
END;


DELIMITER ;