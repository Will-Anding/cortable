*! cortable version 1.4.0
*! Correlation table: lower triangle, RTF export, bold or star significance, column splitting
*! Fix: full rectangular grid so table is navigable in Word (empty cells in upper triangle)

program define cortable
    version 14.0

    syntax varlist [if] [in] [using/], ///
        [SIGlevel(real 0.05)           ///
         DECimals(integer 3)           ///
         SIGstyle(string)              ///
         SPLITat(integer 0)]

    // ── Validate siglevel ────────────────────────────────────────────────────
    if `siglevel' <= 0 | `siglevel' >= 1 {
        di as error "siglevel() must be between 0 and 1 (e.g. 0.05)"
        exit 198
    }

    // ── Validate decimals ────────────────────────────────────────────────────
    if `decimals' < 0 | `decimals' > 10 {
        di as error "decimals() must be between 0 and 10"
        exit 198
    }

    // ── Validate sigstyle ────────────────────────────────────────────────────
    if `"`sigstyle'"' == "" local sigstyle "bold"
    if `"`sigstyle'"' != "bold" & `"`sigstyle'"' != "star" {
        di as error "sigstyle() must be either bold or star"
        exit 198
    }

    // ── Validate splitat ─────────────────────────────────────────────────────
    if `splitat' < 0 {
        di as error "splitat() must be a positive integer, or 0 to disable splitting"
        exit 198
    }

    // ── Sample ───────────────────────────────────────────────────────────────
    marksample touse, novarlist

    local nvars : word count `varlist'
    if `nvars' < 2 {
        di as error "cortable requires at least 2 variables"
        exit 198
    }

    // ── Collect variable labels ───────────────────────────────────────────────
    forvalues i = 1/`nvars' {
        local v : word `i' of `varlist'
        local lbl : variable label `v'
        if `"`lbl'"' == "" local lbl "`v'"
        local label`i' `"`lbl'"'
    }

    // ── Compute pairwise correlations ────────────────────────────────────────
    tempname R P
    matrix `R' = J(`nvars', `nvars', .)
    matrix `P' = J(`nvars', `nvars', .)

    forvalues i = 1/`nvars' {
        local vi : word `i' of `varlist'
        forvalues j = 1/`nvars' {
            local vj : word `j' of `varlist'
            if `i' == `j' {
                matrix `R'[`i',`j'] = 1
                matrix `P'[`i',`j'] = 0
            }
            else if `i' > `j' {
                quietly pwcorr `vi' `vj' if `touse', sig
                matrix `R'[`i',`j'] = r(C)[1,2]
                matrix `P'[`i',`j'] = r(sig)[1,2]
            }
        }
    }

    // ── Output filename ───────────────────────────────────────────────────────
    if `"`using'"' == "" {
        local outfile "cortable.rtf"
    }
    else {
        local outfile `"`using'"'
        if index(`"`outfile'"', ".") == 0 local outfile `"`outfile'.rtf"'
    }

    // ── Column split logic ────────────────────────────────────────────────────
    // Lower triangle has nvars-1 data columns (1 through nvars-1).
    local max_datacol = `nvars' - 1

    if `splitat' <= 0 | `splitat' >= `max_datacol' {
        local n_panels = 1
        local panel1_cs = 1
        local panel1_ce = `max_datacol'
    }
    else {
        local n_panels = ceil(`max_datacol' / `splitat')
        forvalues p = 1/`n_panels' {
            local panel`p'_cs = (`p' - 1) * `splitat' + 1
            local panel`p'_ce = min(`p' * `splitat', `max_datacol')
        }
    }

    // ── Column widths (twips) ─────────────────────────────────────────────────
    local cw_rownum  = 400
    local cw_varname = 1800
    local cw_data    = 900

    local fmt "%12.`decimals'f"

    // ── Open RTF file ─────────────────────────────────────────────────────────
    tempname fh
    file open `fh' using `"`outfile'"', write replace text

    file write `fh' "{\rtf1\ansi\ansicpg1252\deff0" _n
    file write `fh' "{\fonttbl{\f0\froman\fcharset0 Times New Roman;}}" _n
    file write `fh' "{\colortbl;\red0\green0\blue0;}" _n
    file write `fh' "\paperw15840\paperh12240\margl720\margr720\margt720\margb720\landscape" _n
    file write `fh' "\widowctrl\f0\fs20" _n

    // ── Loop over panels ──────────────────────────────────────────────────────
    forvalues p = 1/`n_panels' {

        local cs = `panel`p'_cs'
        local ce = `panel`p'_ce'
        local ncols = `ce' - `cs' + 1

        if `p' > 1 {
            file write `fh' "\pagebb\page" _n
        }

        if `n_panels' > 1 {
            file write `fh' "\pard\sb120\b Correlations (continued: columns `cs'--`ce')\b0\par" _n
        }
        else {
            file write `fh' "\pard\sb120\b Correlations\b0\par" _n
        }
        file write `fh' "\pard\sb60\par" _n

        // ── Helper: write full row of cell boundary definitions ───────────────
        // Every row always defines: rownum + varname + ncols data cells
        // This is the key fix — every row has identical cell structure

        // ── Header row ────────────────────────────────────────────────────────
        file write `fh' "{\trowd\trgaph40\trrh280" _n

        local pos = `cw_rownum'
        file write `fh' "\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\cellx`pos'" _n

        local pos = `cw_rownum' + `cw_varname'
        file write `fh' "\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\cellx`pos'" _n

        forvalues jj = 1/`ncols' {
            local pos = `cw_rownum' + `cw_varname' + `jj' * `cw_data'
            file write `fh' "\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\cellx`pos'" _n
        }

        file write `fh' "\pard\intbl\qc\cell" _n
        file write `fh' "\pard\intbl\ql\b Variable\b0\cell" _n
        forvalues jj = 1/`ncols' {
            local j = `cs' + `jj' - 1
            file write `fh' "\pard\intbl\qc `j'\cell" _n
        }
        file write `fh' "\row}" _n

        // ── Data rows: ALL nvars rows, full rectangle each time ───────────────
        forvalues i = 1/`nvars' {

            file write `fh' "{\trowd\trgaph40\trrh260" _n

            // Always define the full set of cells for this panel
            local pos = `cw_rownum'
            file write `fh' "\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\cellx`pos'" _n

            local pos = `cw_rownum' + `cw_varname'
            file write `fh' "\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\cellx`pos'" _n

            forvalues jj = 1/`ncols' {
                local pos = `cw_rownum' + `cw_varname' + `jj' * `cw_data'
                file write `fh' "\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10\cellx`pos'" _n
            }

            // Row number
            file write `fh' "\pard\intbl\qc `i'\cell" _n

            // Variable label (italic)
            file write `fh' "\pard\intbl\ql\i `label`i''\i0\cell" _n

            // Data cells — always emit exactly ncols cells
            forvalues jj = 1/`ncols' {
                local j = `cs' + `jj' - 1

                // Determine what goes in cell (i, j):
                // - j > i: upper triangle — empty cell
                // - j == i: diagonal — bold 1.000
                // - j < i: lower triangle — correlation value

                if `j' > `i' {
                    // Upper triangle: empty cell, still bordered
                    file write `fh' "\pard\intbl\qc\cell" _n
                }
                else if `j' == `i' {
                    // Diagonal: bold 1.000
                    local diag_str : display %12.`decimals'f 1
                    local diag_str = trim("`diag_str'")
                    file write `fh' "\pard\intbl\qc\b `diag_str'\b0\cell" _n
                }
                else {
                    // Lower triangle: correlation
                    local rij = `R'[`i',`j']
                    local pij = `P'[`i',`j']
                    local coef_str : display `fmt' `rij'
                    local coef_str = trim("`coef_str'")
                    local sig = (`pij' <= `siglevel')

                    if `"`sigstyle'"' == "bold" {
                        if `sig' {
                            file write `fh' "\pard\intbl\qc\b `coef_str'\b0\cell" _n
                        }
                        else {
                            file write `fh' "\pard\intbl\qc `coef_str'\cell" _n
                        }
                    }
                    else {
                        if `sig' {
                            file write `fh' "\pard\intbl\qc `coef_str'*\cell" _n
                        }
                        else {
                            file write `fh' "\pard\intbl\qc `coef_str'\cell" _n
                        }
                    }
                }
            }

            file write `fh' "\row}" _n
        }

        // ── Note on last panel only ───────────────────────────────────────────
        if `p' == `n_panels' {
            if `"`sigstyle'"' == "bold" {
                file write `fh' "\pard\sb80\i Note: Bold coefficients are statistically significant at the `siglevel' level (two-tailed). Lower triangle shown.\i0\par" _n
            }
            else {
                file write `fh' "\pard\sb80\i Note: * indicates statistical significance at the `siglevel' level (two-tailed). Lower triangle shown.\i0\par" _n
            }
        }
    }

    file write `fh' "}" _n
    file close `fh'

    di as text `"Correlation table saved to: `outfile'"'
    di as text "Variables:             `nvars'"
    di as text "Significance level:    `siglevel'"
    di as text "Significance style:    `sigstyle'"
    di as text "Decimal places:        `decimals'"
    if `splitat' > 0 {
        di as text "Split at column:       `splitat' (`n_panels' panel(s))"
    }

end
