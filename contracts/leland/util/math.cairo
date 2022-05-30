%lang starknet

func power(x, n : felt) -> (pow : felt):
    with_attr error_message("n must be positive"):
        if n == 0:
            return (pow=1)
        end
        if n == 1:
            return (pow=x)
        end
        let (pow) = power(x, n - 1)
        return (pow=x * pow)
    end
end