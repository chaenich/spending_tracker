require_relative( '../db/sql_runner' )

class Tag

  attr_reader( :tag_name, :id )

  def initialize( options )
    @id = options['id'].to_i if options['id']
    @tag_name = options['tag_name']
  end

  def save()
    sql = "INSERT INTO tags
    (
      tag_name
    )
    VALUES
    (
      $1
    )
    RETURNING id"
    values = [@tag_name]
    results = SqlRunner.run( sql, values )
    @id = results.first()['id'].to_i
  end

  def update()
    sql = "
    UPDATE tags
      SET tag_name = $1
      WHERE id = $2"
    values = [@tag_name, @id]
    SqlRunner.run( sql, values )
  end

  def delete()
    sql = "DELETE FROM tags WHERE id = $1"
    values = [@id]
    SqlRunner.run( sql, values )
  end


  def self.find(id)
    sql = "SELECT * FROM tags WHERE id = $1"
    values = [id]
    result = SqlRunner.run( sql, values ).first
    return Tag.new( result )
  end

  def self.all()
    sql = "SELECT * FROM tags"
    tags = SqlRunner.run( sql )
    return Tag.map_all( tags )
  end

  def self.delete_all()
    sql = "DELETE FROM tags"
    SqlRunner.run( sql )
  end

  def self.map_all( tags_data )
    tags = tags_data.map { |tag| Tag.new( tag )}
    return tags
  end

  def self.transactions_total(id)
    sql = "SELECT SUM(amount)
      FROM transactions
      WHERE tag_id = $1"
    values = [id]
    result = SqlRunner.run( sql, values ).first
    return result["sum"].to_i
  end

  def self.transactions_detail(id)
    sql = "SELECT tr.amount, t.tag_name, m.merchant_name
      FROM transactions tr, tags t, merchants m
      WHERE t.id = tr.tag_id and
      tr.merchant_id = m.id and t.id = $1"
    values = [id]
    tag_transactions_data = SqlRunner.run( sql, values )
    tag_transactions = tag_transactions_data.map {|tag_transaction| tag_transaction }
    return tag_transactions
  end

end
