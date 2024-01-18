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

r <- httr::GET(url_estabelecimento)

r |>
  xml2::read_html() |>
  xml2::xml_find_all("//img") |>
  xml2::xml_attr("src")

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
