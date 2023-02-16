set -euxo pipefail

filename=$(basename $1 .tex)
pdfname="${filename}.pdf"
svgname="${filename}.svg"

latexmk -shell-escape -pdf $1
pdf2svg $pdfname $svgname
latexmk -shell-escape -c $1