module BreakerAndMaker
	private

	def evaluate_feedback(guess, potential_code)
		exact_matches = 0
		near_matches = 0
		secret_code_remaining = potential_code.dup.split("")

		(0..3).each do |i|
			if guess[i] == potential_code[i]
				exact_matches += 1
				secret_code_remaining[i] = nil
			end
		end

		(0..3).each do |i|
			next if guess[i] == potential_code[i]

			if secret_code_remaining.include?(guess[i])
				near_matches += 1
				secret_code_remaining[secret_code_remaining.index(guess[i])] = nil
			end
		end

		{"exact_matches": exact_matches, "near_matches": near_matches}
	end

	def valid_code?(guess)
		guess.length == 4 && guess.split("").all? {|char| char.to_i.between?(1, 6) }
	end
end

module AI

  private

  def get_AI_guess(turns)
		@initial_guesses ||= ["1", "2", "3", "4", "5", "6"].shuffle
		@numbers_included ||= []
    return final_guesses if @numbers_included.length == 4

    initial_guesses(turns)
  end

  def initial_guesses(turns)
		@first_final_guess ||= true
    guess = @numbers_included.join
    guess << @initial_guesses[turns - 1] until guess.length == 4

    feedback = evaluate_feedback(guess, @secret_code)
    matches = (feedback[:exact_matches] + feedback[:near_matches]) - @numbers_included.length
    matches.times { @numbers_included.push(@initial_guesses[turns - 1]) }

    guess
  end

  def final_guesses
		@permutations ||= []
		if @first_final_guess == true
			@numbers_included.permutation {|perm| @permutations.push(perm.join) }
			@permutations.uniq!
			@permutations.shuffle!

			@first_final_guess = false
		end

		guess = @permutations.shift
		feedback = evaluate_feedback(guess, @secret_code)
		@permutations.reject! {|perm| evaluate_feedback(guess, perm) != feedback }

		guess
  end
end


class Mastermind
	def game
		choose_game_type
	end

	private

	def choose_game_type
		puts "Would you like to be:\n1. The breaker of the code\n2. The maker of the code?"
		game_type = gets.chomp
		loop do
			break if (1..2).include?(game_type.to_i)
			puts "Invalid input.\nWould you like to be:\n1. The codebreaker\n2. The codemaker"
			game_type = gets.chomp
		end
		game_type == "1" ? CodeBreaker.new.play : CodeMaker.new.play
	end
end

class CodeBreaker
	include BreakerAndMaker

	NUMBERS = ["1", "2", "3", "4", "5", "6"]

	def initialize
		@secret_code = generate_secret_code
		@turns = 1
	end

	def play
		while @turns <= 12
			puts "\nTurn ##{@turns}\n"
			guess = get_player_guess
			feedback = evaluate_feedback(guess, @secret_code)
			if feedback[:exact_matches] == 4
				puts "You guessed the correct code!"
				break
			else
				puts "Exact matches: #{feedback[:exact_matches]}\nNear matches: #{feedback[:near_matches]}"
				@turns += 1
			end
		end
		puts "Bad luck! You ran out of guesses! The code was #{@secret_code}." if @turns == 13
	end

	private

	def generate_secret_code
		Array.new(4) { NUMBERS.sample }.join
	end

	def get_player_guess
		puts "Enter your guess. It must be a 4-digit number using only the digits 1-6 (e.g. 1234):"
		guess = gets.chomp
		until valid_code?(guess)
			puts "Invalid guess. Please enter a 4-digit number using only the digits 1-6:"
			guess = gets.chomp
		end
		guess
	end
end

class CodeMaker
	include BreakerAndMaker, AI

	def initialize
		@secret_code = choose_secret_code
		@turns = 1
	end

	def play
		while @turns <= 12
			sleep(1)
			puts "\nTurn ##{@turns}\n"
			guess = get_AI_guess(@turns)
			sleep(1)
			puts guess
			feedback = evaluate_feedback(guess, @secret_code)
			if feedback[:exact_matches] == 4
				puts "Oh no! The computer guessed the correct code!"
				break
			else
				puts "Exact matches: #{feedback[:exact_matches]}\nNear matches: #{feedback[:near_matches]}"
				@turns += 1
			end
		end
		puts "The computer ran out of guesses and couldn't crack your code! Well done!" if @turns == 13
	end

	private

	def choose_secret_code
		puts "Choose a code for the computer to crack. It must be a 4-digit number using only the digits 1-6 (e.g. 1234):"
		code = gets.chomp
		loop do
			break if valid_code?(code)
			puts "Invalid input. Choose a code for the computer to crack. It must be a 4-digit number using only the digits 1-6 (e.g. 1234):"
			code = gets.chomp
		end
		code
	end
end

game = Mastermind.new
game.game