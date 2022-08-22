require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...9).map { ('a'..'z').to_a[rand(26)] }.join(" ").upcase
  end

  def score
    @letters = params[:token].downcase.split
    @answer = params[:question].split('')
    @result = ''
    @repetitive = @answer.all? { |n| @answer.count(n) <= @letters.count(n) }
    @incl = @answer.all? { |k| @letters.include?(k) }
    wagon_api = URI.open("https://wagon-dictionary.herokuapp.com/#{@answer.join("")}").read
    word_hash = JSON.parse(wagon_api)
    if !word_hash['found'] && @repetitive && @incl
      @result = "'#{@answer.join('')}' is valid according to the grid, but does not seem to be a valid English word"
    elsif @repetitive && word_hash['found'] && @incl
      @result = 'The word is valid according to the grid and is an English word'
      session[:score] = session[:score] + @answer.length
    else
      @result = "Sorry, but '#{@answer.join('').upcase}' can’t be built out of '#{@letters.join('-').upcase}'."
    end
  end
end
