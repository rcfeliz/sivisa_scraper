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

r <- httr2::request(url_estabelecimento) |>
  httr2::req_perform()

jsessionid <- r$headers$`Set-Cookie` |>
  stringr::str_extract("\\w+(?=;)")

url_referer <- paste0(url_estabelecimento, ";jsession=", jsessionid)

url_captcha <- "https://sivisa.saude.sp.gov.br/sivisa/jcaptcha"

path_captcha <- "data-raw/captcha/captcha.jpeg"

url_captcha |>
  httr2::request() |>
  httr2::req_headers('Referer' = url_referer) |>
  httr2::req_perform(path =path_captcha)

captcha <- captcha::read_captcha(path_captcha)
plot(captcha)
model <- captcha::captcha_load_model("tjrs")
captcha::decrypt(captcha, model)

# para exemplo
cnpj <- "11.244.733/0001-98"
municipio_ibge <- "350320"
captcha <- "xs9l"

body <- list(
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.estabelecimento.cpf" = "",
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.estabelecimento.cnpj" = cnpj,
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.estabelecimento.razaoSocialNome" = "",
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.nomeFantasia" = "",
  "ibge_codigo" = municipio_ibge,
  "cevsSolicitacaoIdentificacao.estabelecimentoDados.endereco.logradouro" = "",
  "textoCaptcha" = captcha,
  "pesquisa" = "1",
  "IdNameSemValor" = ""
)

path <- "data-raw/html"

r <- httr::POST(
  url = url_estabelecimento,
  body = body,
  httr::write_disk(path, overwrite = TRUE)
)
