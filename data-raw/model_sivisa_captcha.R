
# preparacao --------------------------------------------------------------

url <- "https://sivisa.saude.sp.gov.br/sivisa/cidadao/cidadaoLicenca.consultaEstabelecimento.logic"

url_captcha <- "https://sivisa.saude.sp.gov.br/sivisa/jcaptcha"

path_captcha <- "data-raw/captcha"

# annotate ----------------------------------------------------------------
for(i in 1:100) {
  r <- httr2::request(url) |>
    httr2::req_perform()

  jsessionid <- r$headers$`Set-Cookie` |>
    stringr::str_extract("\\w+(?=;)")

  url_referer <- paste0(url_estabelecimento, ";jsession=", jsessionid)

  f <- fs::path(path_captcha, jsessionid, ext = "jpeg")

  url_captcha |>
    httr2::request() |>
    httr2::req_headers('Referer' = url_referer) |>
    httr2::req_perform(path = f)

  captcha::captcha_annotate(file = f, rm_old = TRUE)
}

del <- list.files(path_captcha, recursive = TRUE, pattern="naosei[.]jpeg$")

paste0(path_captcha, "/", del) |>
  file.remove()
