
# preparacao --------------------------------------------------------------

url <- "https://sivisa.saude.sp.gov.br/sivisa/cidadao/"

servicos <- list(
  descricao = c(
    "Consulta de Licenças",
    "Consulta Validação da Licença",
    "Consulta Estabelecimento",
    "Autenticidade da Ficha de Procedimento"
  ),
  endpoint = c(
    "cidadaoLicenca.consulta.logic",
    "cidadaoLicenca.consultaValidacao.logic",
    "cidadaoLicenca.consultaEstabelecimento.logic",
    "autentica/"
  )
)

url_estabelecimento <- paste0(url, servicos$endpoint[servicos$descricao == "Consulta Estabelecimento"])

url_captcha <- "https://sivisa.saude.sp.gov.br/sivisa/jcaptcha"

model <- captcha::captcha_fit_model(dir = "data-raw/captcha")

# body --------------------------------------------------------------------

# captcha
r <- httr2::request(url_estabelecimento) |>
  httr2::req_perform()

jsessionid <- r$headers$`Set-Cookie` |>
  stringr::str_extract("\\w+(?=;)")

url_referer <- paste0(url_estabelecimento, ";jsession=", jsessionid)

path_captcha <- "data-raw/img/captcha.jpeg"

url_captcha |>
  httr2::request() |>
  httr2::req_headers('Referer' = url_referer) |>
  httr2::req_perform(path = path_captcha)

captcha <- captcha::read_captcha(path_captcha)
plot(captcha)
# model <- captcha::captcha_fit_model(dir = "data-raw/captcha")
captcha_answer <- captcha::decrypt(captcha, model)

# cnpj
cnpj <- "11.244.733/0001-98"
municipio_ibge <- "350320"

body <- list(
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.estabelecimento.cpf" = "",
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.estabelecimento.cnpj" = cnpj,
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.estabelecimento.razaoSocialNome" = "",
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.nomeFantasia" = "",
  "ibge_codigo" = municipio_ibge,
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.endereco.logradouro" = "",
  "textoCaptcha" = captcha_answer,
  "pesquisa" = "1",
  "IdNameSemValor" = ""
)

path_html <- "data-raw/html"

file_html <- fs::path(path_html, jsessionid, ext = "html")

r <- httr::POST(
  url = url_referer,
  body = body,
  httr::write_disk(file_html, overwrite = TRUE)
)

