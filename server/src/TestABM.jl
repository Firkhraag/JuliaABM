module TestABM

using Genie

const up = Genie.up
export up

const down = Genie.down
export down

function main()
  Genie.genie(; context = @__MODULE__)
end

end
