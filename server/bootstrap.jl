(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using TestABM
const UserApp = TestABM
TestABM.main()
