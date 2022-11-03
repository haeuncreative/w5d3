require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end
#---------------------------------------------------------------------------------------------
class User
    attr_accessor :id, :fname, :lname, :author_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
            SELECT 
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0
        User.new(user[0])
    end

    def self.find_by_id(id)
        user = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                users
            WHERE
                id = ?
            SQL
        return nil unless user.length > 0
        User.new(user[0])
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        authored_questions_arr = [Question.find_by_author_id(self.id)]
    end

    def authored_replies
        authored_replies_arr = [Reply.find_by_author_id(self.id)]
    end

    def followed_questions
        follower_id = @id
        QuestionFollow.followed_questions_for_user_id(follower_id)
    end

end
#---------------------------------------------------------------------------------------------
class Question 
    attr_accessor :id, :title, :body, :author_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum) }
    end

    def self.find_by_id(id)
        question = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
            SQL
        return nil unless question.length > 0
        Question.new(question[0])
    end

    def self.find_by_author_id(author_id)
        question = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
        SELECT
            *
        FROM
            questions
        WHERE
            author_id = ?
        SQL
    
        return nil unless question.length > 0

        Question.new(question[0])
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

    def author
        QuestionsDBConnection.instance.execute(<<-SQL, author_id)
        SELECT
            *
        FROM
            users
        WHERE
           id = ?
        SQL
    end

    def replies
        # Reply.find_by_author_id(author_id)
        question_id = @id 
        replies = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
            reply_body
        FROM
            replies
        WHERE
           question_id = ?
        SQL

        replies.map {|reply| Reply.new(reply)}
    end

    def followers
        question_id = @id
        QuestionFollow.followers_for_question_id(question_id)
    end


end
#---------------------------------------------------------------------------------------------
class QuestionFollow
    attr_accessor :id, :follower_id, :question_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def self.find_by_id(id)
        question_follow = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
            SQL
        return nil unless question_follow.length > 0
        QuestionFollow.new(question_follow[0])
    end

    def self.followers_for_question_id(question_id)
        question_follow = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                fname, lname
            FROM
                users
            JOIN question_follows
                ON users.id = question_follows.follower_id 
            WHERE
                question_id = ?
            SQL
    end

    def self.followed_questions_for_user_id(follower_id)
        question_follow = QuestionsDBConnection.instance.execute(<<-SQL, follower_id)
            SELECT
                title, body
            FROM
                questions
            JOIN question_follows
                ON questions.id = question_follows.question_id

            WHERE
                follower_id = ?
            SQL
    end

    def self.most_followed_questions(n)
        most_followed = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT
                title, COUNT(follower_id)
            FROM 
                question_follows
            JOIN 
                users ON users.id = question_follows.follower_id 
            JOIN 
                questions ON questions.id = question_follows.question_id
                ORDER BY follower_id 
                LIMIT ?
        SQL
    end

    

    def initialize(options)
        @id = options['id']
        @follower_id = options['follower_id']
        @question_id = options['question_id']
    end


end
#---------------------------------------------------------------------------------------------
class Reply
    attr_accessor :id, :parent_reply_id, :question_id, :author_id, :reply_body

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(id)
        reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
            SQL
        return nil unless reply.length > 0
        Reply.new(reply[0])
    end

    def self.find_by_question_id(question_id)
        reply = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ?
            SQL
        return nil unless reply.length > 0
        Reply.new(reply[0])
    end


    def self.find_by_author_id(author_id)
        reply = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
        SELECT
            *
        FROM
            replies
        WHERE
            author_id = ?
        SQL
        return nil unless reply.length > 0
        Reply.new(reply[0])
    end    


    def initialize(options)
        @id = options['id']
        @parent_reply_id = options['parent_reply_id']
        @question_id = options['question_id']
        @author_id = options['author_id']
        @reply_body = options['reply_body']
    end

    def author
        QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT
            fname , lname
        FROM
            users
        WHERE
           id = ?
        SQL
    end

    def question 
        question = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT
            title, body
        FROM
            questions
        WHERE
           id = ?
        SQL
        return nil unless question.length > 0
        question.map { |ques| Question.new(ques) }
    end

    def parent_reply
        Reply.find_by_id(parent_reply_id)
        # parent_reply = QuestionsDBConnection.instance.execute(<<-SQL, parent_reply_id)
        # SELECT
        #     id
        # FROM
        #     replies
        # WHERE
        #    id = ? --does this need to be id only (along time the parameter above?)
        # SQL
        # # return nil unless parent_reply.length > 0
        # parent_reply[0]
    end

    def child_replies
        child_replies = QuestionsDBConnection.instance.execute(<<-SQL, parent_reply_id)
        SELECT
            reply_body 
        FROM
            replies
        WHERE 
           parent_reply_id = ? 
        SQL
        return nil unless child_replies.length > 0
        child_replies.map { |reply| Reply.new(reply).reply_body }
        # return 'no child replies :(' if @author_id == nil

    end


end




#---------------------------------------------------------------------------------------------






class QuestionLike
    attr_accessor :id, :question_id, :users_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
        data.map { |datum| QuestionLike.new(datum) }
    end

    def self.find_by_id(id)
        question_like = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_likes
            WHERE
                id = ?
            SQL
        return nil unless question_like.length > 0
        QuestionLike.new(question_like[0])
    end

    def self.likers_for_question_id(question_id)
        likers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                fname, lname
            FROM
                users
            JOIN
                question_likes ON users.id = question_likes.users_id
            WHERE
                question_id = ?
        SQL
    end

    def self.num_likes_for_question_id(question_id)
        likers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
            COUNT(fname)
        FROM
            users
        JOIN
            question_likes ON users.id = question_likes.users_id
        WHERE
            question_id = ?
        SQL
        
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @users_id = options['users_id']
    end


end

#---------------------------------------------------------------------------------------------


