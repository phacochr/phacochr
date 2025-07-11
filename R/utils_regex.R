regex_remove_postcode <- function(string) {
  table_postal_com_name <- readr::read_csv2(
    paste0(path_data,"BeST/PREPROCESSED/table_postal_com_name.csv"),
    progress = F,
    col_types = cols(.default = col_character())
  ) |> pull(CP_NAME)

  cp_names_regex <- str_c(table_postal_com_name, collapse = "|")

  string |>
    str_replace(regex(str_c("\\b(?<!\\-)(", cp_names_regex,")\\b(?!\\-)"), ignore_case = TRUE), " ") |>
    str_replace(regex("([0-9]{4}\\s[\\p{Letter}-' ]+\\z)|([0-9]{4}(|\\s)\\z)", ignore_case = TRUE), " ")

}

regex_remove_boite <- function(string) {
  str_replace(string, regex("(^|\\s)(bt(e|[.]|)|bo(i|\u00ee)te|bus)(|\\s)([0-9]+|[a-zA-Z]\\b)", ignore_case = TRUE), " ")
}

regex_remove_BP_CP <- function(string) {
  str_replace(string, regex("\\s(BP|CP)(|\\s)[0-9]+|^(BP|CP)(|\\s)[0-9]+", ignore_case = TRUE), " ")
}

regex_remove_numero <- function(string) {
  str_replace(string, regex("n\u00b0|((^|\\s)(num([.]|)|num(\u00e9|e)ro|n(o|)([.]|)|\\sno)(|\\s)[0-9]+)", ignore_case = TRUE), " ")
}

regex_remove_king_num <- function(string) {
  str_replace_all(string, regex("((?<!(\\sd(es|u) )|(Albert( |))|(L(e|\u00e9)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( |)er |( ||i)(\u00e8|e)me |( |)de |(-|)[a-z]{3,}))([^ ,0-9]+))|(([^ ,0-9]+)(?<!(\\sd(es|u) )|(Albert( |))|(L(e|\u00e9)opold( |))|(Baudouin( |))|([a-z]{3,20}))([0-9]++)(?!(( |)e |( ||i)(\u00e8|e)me |( |)de |( |)er )))|(?<!(\\sd(es|u) )|(Albert( |))|(L(e|\u00e9)opold( |))|(Baudouin( |)))([0-9]++)(?!(( |)e |( ||i)(\u00e8|e)me |( |)de |( |)er ))", ignore_case = TRUE), " ")
}

regex_remove_rez <- function(string) {
  str_replace(string, regex("\\sRez\\s", ignore_case = TRUE), " ")
}

regex_remove_bis <- function(string) {
  str_replace(string, regex("\\sBis\\s", ignore_case = TRUE), " ")
}

regex_remove_rdc <- function(string) {
  str_replace(string, regex("\\sRdc\\s", ignore_case = TRUE), " ")
}

regex_fix_commandant <- function(string) {
  str_replace(string, regex("(c(m|)dt([.]|)(\\s|))", ignore_case = TRUE), "Commandant ")
}

regex_fix_lieutenant <- function(string) {
  str_replace(string, regex("(^lt[.](\\s|)|^lt\\s)", ignore_case = TRUE), "Luitenant ") |>
    str_replace(regex("((?<!^)\\s+lt[.](\\s|)|(?<!^)\\s+lt\\s)", ignore_case = TRUE), " Lieutenant ")
}

regex_fix_saint <- function(string) {
  str_replace(string, regex("((\\sst[.][-]))|(\\sst(\\s|[-]|[.]))", ignore_case = TRUE), " Saint ") |>
    str_replace(regex("((^st[.][-])|(^st(\\s|[-]|[.])))", ignore_case = TRUE), "Sint ") |>
    str_replace(regex("(\\ss|^s)te(\\s|[-])", ignore_case = TRUE), " Sainte ")
}

regex_fix_chaussee <- function(string) {
  str_replace(string, regex("(^ch(s|)(\u00e9|e)e\\s|^ch([.]|\\s))", ignore_case = TRUE), "Chaussee ")
}

regex_fix_avenue <- function(string) {
  str_replace(string, regex("(^av[.](\\s|)|^av(e|)\\s)", ignore_case = TRUE), "Avenue ")
}

regex_fix_koning <- function(string) {
  #(\\s|) should be \\s?
  str_replace(string, regex("(^kon[.](\\s|)(?=(elisabet|astrid))|^kon\\s)(?=(elisabet|astrid))", ignore_case = TRUE), "Koningin ") |>
    str_replace(regex("(^kon[.](\\s|)(?!(elisabet|astrid))|^kon\\s)(?!(elisabet|astrid))", ignore_case = TRUE), "Koning ")
}

regex_fix_professor <- function(string) {
  str_replace(string, regex("(^prof[.](\\s|)|^prof\\s)", ignore_case = TRUE), "Professor ")
}

regex_fix_square <- function(string) {
  str_replace(string, regex("(^sq[.](\\s|)|^sq\\s)", ignore_case = TRUE), "Square ")
}

regex_fix_steenweg <- function(string) {
  str_replace(string, regex("stwg(\\s|[.])", ignore_case = TRUE), "steenweg")}

regex_fix_burgemeester <- function(string) {
  str_replace(string, regex("(^burg[.](\\s|)|^burg\\s)", ignore_case = TRUE), "Burgemeester ")
}

regex_fix_dokter <- function(string) {
  str_replace(string, regex("(^dr[.](\\s|)|^dr\\s)", ignore_case = TRUE), "Dokter ") |>
    str_replace(regex("((?<!^)\\s+dr[.](\\s|)|(?<!^)\\s+dr\\s)", ignore_case = TRUE), " Docteur ")
}

regex_fix_boulevard <- function(string) {
  str_replace(string, regex("((^b(|l)(|v)d(|[.])\\s)|(^b(|l)(|v)d[.]))", ignore_case = TRUE), "Boulevard ")
}

regex_fix_route <- function(string) {
  str_replace(string, regex("^Rte\\s", ignore_case = TRUE), "Route ")
}

regex_fix_place <- function(string) {
  str_replace(string, regex("^pl\\s", ignore_case = TRUE), "Place ")
}

regex_fix_rue <- function(string) {
  str_replace(string, regex("^de\\sla\\s", ignore_case = TRUE), "Rue de la ") |>
    str_replace(regex("^du\\s", ignore_case = TRUE), "Rue du ") |>
    str_replace(regex("^des\\s", ignore_case = TRUE), "Rue des ") |>
    str_replace(regex("^d[']", ignore_case = TRUE), "Rue d'") |>
    str_replace(regex("^de\\s", ignore_case = TRUE), "Rue de ") |>
    str_replace(regex("^r\\s", ignore_case = TRUE), "Rue ") |>
    str_replace(regex("^de\\sl(\\s|)[']", ignore_case = TRUE), "Rue de l'") |>
    str_replace(regex("de\\sl\\s([']|)", ignore_case = TRUE), "de l'") |>
    str_replace(regex("rue\\sd\\s", ignore_case = TRUE), "Rue d'") |>
    str_replace(regex("[']\\s", ignore_case = TRUE), "'")
}


regex_remove_trailling_single_letters <- function(string, n) {
  str_squish(string) |>
    Reduce(init = _, x = 1:n, f = \(string, x) {
      str_replace(string, regex("(?<=\\s)[A-Za-z]$", ignore_case = TRUE), " ") |>
        str_squish()
    })
}

regex_remove_tiret <- function(string) {
  str_replace(string, regex("([-]$|^[-])", ignore_case = TRUE), " ")
}

regex_correct_street <- function(string){
  string |>
    str_replace_all("[,:/]|[(].*[)]", " ") |>
    str_squish() |>
    regex_remove_boite() |>
    regex_remove_BP_CP() |>
    regex_remove_numero() |>
    regex_remove_king_num() |>
    regex_remove_rez() |>
    regex_remove_bis() |>
    regex_remove_rdc() |>
    regex_fix_commandant() |>
    regex_fix_lieutenant() |>
    regex_fix_saint() |>
    str_squish() |>  # To check if different bc was trim left
    regex_fix_chaussee() |>
    regex_fix_avenue() |>
    regex_fix_koning() |>
    regex_fix_professor() |>
    regex_fix_square() |>
    regex_fix_steenweg() |>
    regex_fix_burgemeester() |>
    regex_fix_dokter() |>
    regex_fix_boulevard() |>
    regex_fix_route() |>
    regex_fix_place() |>
    regex_fix_rue() |>
    regex_remove_trailling_single_letters(n = 2) |>
    regex_remove_tiret() |>
    str_squish()
}

