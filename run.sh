ruby render.rb > res/_out.ppm
convert res/_out.ppm res/out.png
dot res/_ast.dot -T svg -o res/ast.svg

