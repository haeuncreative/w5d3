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

class User
    attr_accessor :id, :fname, :lname

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
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

end

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

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

end

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


    def initialize(options)
        @id = options['id']
        @follower_id = options['follower_id']
        @question_id = options['question_id']
    end


end

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


end

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


    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @users_id = options['users_id']
    end


end