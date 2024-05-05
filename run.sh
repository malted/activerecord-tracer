ruby render.rb > res/out.ppm
convert res/out.ppm res/out.png
dot res/recursion.dot -T png -o ast.png

