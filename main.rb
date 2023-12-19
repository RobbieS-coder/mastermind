module BreakerAndMaker
	def evaluate_guess(guess)
		exact_matches = 0
		near_matches = 0
		secret_code_remaining = @secret_code.dup.split("")

		(0..3).each do |i|
			if guess[i] == @secret_code[i]
				exact_matches += 1
				secret_code_remaining[i] = nil
			end
		end

		(0..3).each do |i|
			next if guess[i] == @secret_code[i]

			if secret_code_remaining.include?(guess[i])
				near_matches += 1
				secret_code_remaining[secret_code_remaining.index(guess[i])] = nil
			end
		end

		{"exact_matches": exact_matches, "near_matches": near_matches}
	end
end

class Mastermind
	def initialize
		@game = nil
	end

	def start_game
		@game = choose_game_type
		p @game
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
			puts "Turn ##{@turns}\n"
			guess = get_player_guess
			feedback = evaluate_guess(guess)
			if feedback[:exact_matches] == 4
				puts "You guessed the correct code!"
				break
			else
				puts "Exact matches: #{feedback[:exact_matches]}\nNear matches: #{feedback[:near_matches]}"
				@turns += 1
			end
		end
		puts "Bad luck! You ran out of guesses! The code was #{@secret_code}."
	end

	private

	def generate_secret_code
		code = ""
		4.times { code += NUMBERS.sample() }
		code
	end

	def get_player_guess
		puts "Enter your guess. It must be a 4-digit number using only the digits 1-6 (e.g. 1234):"
		guess = gets.chomp
		until valid_guess?(guess)
			puts "Invalid guess. Please enter a 4-digit number using only the digits 1-6:"
			guess = gets.chomp
		end
		guess
	end

	def valid_guess?(guess)
		guess.length == 4 && guess.split("").all? { |char| char.to_i.between?(1, 6) }
	end
end

class CodeMaker
	include BreakerAndMaker
end

game = Mastermind.new
game.start_game