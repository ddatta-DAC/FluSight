#' Remove invalid predicted probabilities for scoring
#'
#' Sets invalid predictied probabilities (i.e. those summing to > 1.1 or < 0.9)
#' to zero. This function should be run prior to scoring an entry to ensure
#' no invalid probabilities are scored.
#'
#' @param entry An entry data.frame with columns location, target, type, unit, 
#'        bin_start_incl, bin_end_incl, and value.
#' @param challenge one of "ilinet", "hospital" or "state_ili", indicating which
#'   challenge the submission is for (default \code{"ilinet"})
#' @return An entry data.frame with invalid probabilities all set to zero.
#' @import dplyr
#' @export
#' @seealso \code{\link{verify_entry}} \code{\link{score_entry}}
#' @examples
#' valid_entry <- remove_invald(full_entry)

remove_invalid <- function(entry, challenge = "ilinet") {
  
  if (!(challenge %in% c("ilinet", "hospital", "state_ili"))) {
    stop("challenge must be one of ilinet, hospital, or state_ili")
  }
  
  # Rename hospitalization entries to work with following code
  if (challenge == "hospital")  entry <- rename(entry, location = age_grp)
  
  entry <- entry %>%
    left_join(entry %>%
                filter(type == "Bin") %>%
                group_by(location, target, type) %>%
                summarize(total = sum(value, na.rm = T)) %>%
                filter(total >= 1.1 | total <= 0.9),
              by = c("location", "target", "type")) %>%
    mutate(value = ifelse(is.na(total), value, NA)) %>%
    select(-total)
  
  # Rename back to hospitalization format
  if (challenge == "hospital") entry <- rename(entry, age_grp = location)
  
  return(entry)

}
