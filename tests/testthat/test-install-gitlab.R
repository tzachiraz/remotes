context("Install from GitLab")

test_that("install_gitlab", {

  skip_on_cran()
  skip_if_offline()

  Sys.unsetenv("R_TESTS")

  lib <- tempfile()
  on.exit(unlink(lib, recursive = TRUE), add = TRUE)
  dir.create(lib)

  install_gitlab("jimhester/falsy", lib = lib, quiet = TRUE)

  expect_silent(packageDescription("falsy", lib.loc = lib))
  expect_equal(
    packageDescription("falsy", lib.loc = lib)$RemoteRepo,
    "falsy")

  remote <- package2remote("falsy", lib = lib)
  expect_s3_class(remote, "remote")
  expect_s3_class(remote, "gitlab_remote")
  expect_equal(format(remote), "GitLab")
  expect_equal(remote$host, "gitlab.com")
  expect_equal(remote$username, "jimhester")
  expect_equal(remote$repo, "falsy")
  expect_equal(remote$ref, "master")
  expect_equal(remote$subdir, NULL)
  expect_true(!is.na(remote$sha) && nzchar(remote$sha))
})

test_that("error if not username, warning if given as argument", {

  skip_on_cran()
  skip_if_offline()

  Sys.unsetenv("R_TESTS")

  lib <- tempfile()
  on.exit(unlink(lib, recursive = TRUE), add = TRUE)
  dir.create(lib)

  expect_error(
    install_gitlab("falsy", lib = lib, quiet = TRUE)
  )
})

test_that("remote_download.gitlab_remote messages", {

  mockery::stub(remote_download.gitlab_remote, "download_gitlab", TRUE)
  expect_message(
    remote_download.gitlab_remote(
      remote("gitlab",
        host = "https://gitlab.com",
        username = "jimhester",
        repo = "falsy",
        ref = "master"
      )
    ),
    "Downloading GitLab repo"
  )
})

test_that("remote_sha.gitlab_remote", {

  skip_on_cran()
  skip_if_offline()

  expect_equal(
    remote_sha(
      remote("gitlab",
        host = "https://gitlab.com",
        username = "jimhester",
        repo = "falsy",
        ref = "1.0"
      )
    ),
    "0f39d9eb735bf16909831c0bb129063dda388375"
  )

})

