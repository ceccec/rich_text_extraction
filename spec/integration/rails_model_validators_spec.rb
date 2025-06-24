# frozen_string_literal: true

require 'spec_helper'
require 'active_record'
require 'rich_text_extraction'

RSpec.describe 'Validators in a real Rails model' do
  before(:all) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Base.connection.create_table(:books) do |t|
      t.string :isbn
      t.string :vin
      t.string :website
    end

    class Book < ActiveRecord::Base
      validates :isbn, isbn: true
      validates :vin, vin: true
      validates :website, url: true
    end
  end

  it 'validates ISBN, VIN, and URL in a real model' do
    book = Book.new(isbn: '978-3-16-148410-0', vin: '1HGCM82633A004352', website: 'https://example.com')
    expect(book).to be_valid

    book.isbn = 'invalid'
    expect(book).not_to be_valid
    expect(book.errors[:isbn]).to be_present
  end
end 