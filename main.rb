class Mastermind
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
	end

	private

	def generate_secret_code
		code = ""
		4.times { code += NUMBERS.sample() }
		code
	end

	def get_player_guess
		puts "Enter your guess (e.g. 1234):"
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

game = Mastermind.new
game.play