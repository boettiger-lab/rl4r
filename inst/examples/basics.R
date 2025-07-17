

reticulate::py_require(c("gymnasium", "numpy"))
gym <- reticulate::import("gymnasium")
np <- reticulate::import("numpy")

step_fn <- function(self, action) {

    X <- self$state
    p <- self$config$parameters

    # 'action' space should be in (-1, 1)
    h <- (action + 1 ) / 2
    
    # Reward
    reward <- min(h, X) # cannot harvest more than x

    # Harvest
    X <- min(X - h, 0)

    # Recruit
    X <- X + p["r"] * X * (1 - X / p["k"]) + X * rnorm(1, 0, p["sigma_x"])

    # Advance time counter
    self$time <- self$time + 1

    # Game-over conditions
    truncated <- FALSE
    terminated <- FALSE
    if (X <= 0) {
        truncated <- TRUE
    }
    if (self$config$Tmax >= self$time) {
        terminated <- TRUE
    }

    # 'state' space should be in (-1, 1)
    self$state <- 2 * X - 1

    # catch-all place to provide additional information to user/other functions
    info = list()

    # must have this return type
    list(observation, reward, terminated, truncated, info)
}

reset_fn <- function(self, seed = NULL, options = NULL) {
    
    self$state <- self$config$init_state
    self$time <- 0
    observation <- self$state
    info <- list()

    # must have this return
    list(observation, info)
}

action_space <- gym$spaces$Box(low = -1, high = 1, dtype = np$float32)
observation_space <- gym$spaces$Box(low = -1, high = 1, dtype = np$float32)

classes <- reticulate::py_run_file("inst/python/basic_class.py")
config <- list(Tmax = 0, init_X = 0.5)
fish <- classes$CustomEnv(action_space,
                          observation_space,
                          reticulate::r_to_py(step_fn),
                          reticulate::r_to_py(reset_fn),
                          config)



create_class <- function(action_space,  observation_space,  step_fn, reset_fn, config) {

}