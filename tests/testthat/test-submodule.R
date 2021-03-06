context("submodule.R")

test_that("parse_submodules works with a single submodule", {
  x <-
'[submodule "foobar"]
  path = baz
  url = http://foo/bar'

  expect_equal(
    parse_submodules(x),
    data.frame(
      submodule = "foobar",
      path = "baz",
      url = "http://foo/bar",
      branch = NA_character_,
      stringsAsFactors = FALSE))
})

test_that("parse_submodules works multiple submodules", {
  y <-
'[submodule "foobar"]
  path = baz
  url = http://foo/bar

[submodule "foofoo"]
  path = bunny
  url = http://little/bunny/foofoo
  branch = forest'

  expect_equal(
    parse_submodules(y),
    data.frame(
      submodule = c("foobar", "foofoo"),
      path = c("baz", "bunny"),
      url = c("http://foo/bar", "http://little/bunny/foofoo"),
      branch = c(NA_character_, "forest"),
      stringsAsFactors = FALSE))
})

test_that("parse_submodules warns and returns empty for invalid submodules", {
  x <-
'[submodule "foobar"]
  path = baz'

  expect_warning(regexp = "Invalid submodule definition",
    expect_equal(
      parse_submodules(x),
      list()
    )
  )

  y <-
'[submodule "foobar"]
  path = baz

[submodule "foofoo"]
  path = bunny
  url = http://little/bunny/foofoo'

  expect_warning(regexp = "Invalid submodule definition",
    expect_equal(
      parse_submodules(y),
      list()
    )
  )

  z <- '
  # [submodule "foobar"] this one is commented out
  # path = baz
  # url = https://foo/bar'

  expect_equal(
    parse_submodules(z),
    list()
  )
})

test_that("Can install a repo with a submodule", {

  if (is.null(git_path())) skip("git is not installed")

  dir <- tempfile()
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  writeLines("foo <- 1", file.path(dir, "foo.R"))

  in_dir(dir, {
    git("init")
    git(paste("add", "-A", "."))
    git(paste(
      # We need to temporarily set the user name and user email,
      # in case they are not set
      "-c", "user.name=foobar", "-c", paste0("user.email=", shQuote("<>")),
      "commit", "-m", shQuote("Initial commit")))
  })
  module <- file.path("submodule", ".gitmodules")
  writeLines(sprintf(
'[submodule "foo"]
	path = R
	url = file://%s
	branch = master',
  URLencode(dir)),module
  )

  on.exit(unlink(module), add = TRUE)

  lib <- tempfile()
  on.exit(unlink(lib, recursive = TRUE), add = TRUE)
  dir.create(lib)

  install_local("submodule", lib = lib, quiet = TRUE)
  withr::with_libpaths(lib,
    expect_equal(submodule::foo, 1)
  )
})
