{smcl}
{* *! version 1.3.0}{...}
{viewerjumpto "Syntax" "cortable##syntax"}{...}
{viewerjumpto "Description" "cortable##description"}{...}
{viewerjumpto "Options" "cortable##options"}{...}
{viewerjumpto "Examples" "cortable##examples"}{...}

{title:Title}

{phang}
{bf:cortable} {hline 2} Export a formatted pairwise correlation table to RTF (Word)

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cortable} {varlist} {ifin} [{cmd:using} {it:filename}]
[{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt:{opt sig:level(#)}}p-value threshold for significance (default: 0.05){p_end}
{synopt:{opt dec:imals(#)}}decimal places for coefficients (default: 3){p_end}
{synopt:{opt sigstyle(string)}}significance indicator: {bf:bold} (default) or {bf:star}{p_end}
{synopt:{opt split:at(#)}}split table every # columns onto a new page (0 = no split){p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cortable} computes pairwise correlations for all variables in {varlist}
and exports a formatted lower-triangle correlation table to a Word-compatible
RTF file.

{pstd}
The {cmd:using} clause is optional. If omitted, the file is saved as
{bf:cortable.rtf} in the current working directory. A {bf:.rtf} extension
is appended automatically if omitted.

{pstd}
Variables are numbered sequentially in the column headers. The leftmost
columns show the row number and variable label (italicised). The diagonal
shows {bf:1.000} in bold.

{marker options}{...}
{title:Options}

{phang}
{opt siglevel(#)} sets the p-value threshold for significance marking.
Default is {cmd:siglevel(0.05)}.

{phang}
{opt decimals(#)} sets the number of decimal places. Default is {cmd:decimals(3)}.

{phang}
{opt sigstyle(string)} controls how significant coefficients are marked.
Specify {bf:bold} (default) to print them in bold, or {bf:star} to append
a single asterisk after the coefficient (e.g. {bf:0.316*}).

{phang}
{opt splitat(#)} splits the table into multiple pages when there are many
variables. Each page contains at most # data columns. For example,
{cmd:splitat(6)} keeps columns 1-6 on the first page, 7-12 on the second,
and so on. Rows are repeated on each page as needed. Specify 0 (the default)
to disable splitting.

{marker examples}{...}
{title:Examples}

{pstd}Simplest usage — defaults (bold, p<0.05, 3 decimals, saves to cortable.rtf):{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. cortable price mpg weight length}{p_end}

{pstd}Use star notation instead of bold:{p_end}
{phang2}{cmd:. cortable price mpg weight length, sigstyle(star)}{p_end}

{pstd}Bold at 10% level, 2 decimal places:{p_end}
{phang2}{cmd:. cortable price mpg weight length, siglevel(0.10) decimals(2)}{p_end}

{pstd}Large table — split every 6 columns onto a new page:{p_end}
{phang2}{cmd:. cortable v1 v2 v3 v4 v5 v6 v7 v8 v9 v10, splitat(6)}{p_end}

{pstd}Stars, 1% level, split at 8, save to a named file:{p_end}
{phang2}{cmd:. cortable v1-v14 using "table3", sigstyle(star) siglevel(0.01) splitat(8)}{p_end}

{title:Author}

{pstd}Custom package. Version 1.3.0.{p_end}
