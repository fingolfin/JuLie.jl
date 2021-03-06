################################################################################
# Cartan Matrices.
#
# Copyright (C) 2020 Ulrich Thiel, ulthiel.com/math
#
# Contributed by Tom Schmit.
#
################################################################################

import AbstractAlgebra: MatElem, MatrixAlgebra, diagonal_matrix, matrix, zero_matrix
import Nemo: fmpz

export is_cartan_matrix, CartanMatrix

"""
    struct CartanMatrix{T} <: MatElem{T}

A (generalized) **Cartan matrix** ``C`` is a square matrix over the integers, satisfying the following rules:

```math
\\begin{aligned}
& C_{i,i} = 2 & \\\\

& C_{i,j} ≤ 0 \\quad \\text{ for } \\quad i≠j \\\\

& C_{i,j} = 0 \\quad \\Leftrightarrow \\quad  C_{j,i} = 0``
\\end{aligned}
```

We implement them as ```MatElem``` from *AbstractAlgebra.jl* over ```fmpz```.

You can create a CartanMatrix with
```
CartanMatrix( "A4~" )     #calls essentially CartanMatrix('A', 4, true)
CartanMatrix( "C6" )      #calls essentially CartanMatrix('C', 6)
```
which generates the CartanMatrix: ``\\tilde{A_4}`` resp. ``C_6``

If you would like to generate block diagonal matrices you can do so with
```
CartanMatrix(["A3~","G2","B12"])    #calls essentially CartanMatrix(['A','G','B'],[3,2,12],[true,false,false])
```
"""
struct CartanMatrix{T} <: MatElem{T}
   cm::MatElem{T}
end


function Base.show(io::IO, mime::MIME"text/plain", CM::CartanMatrix)
  show(io, mime, CM.cm)
end

function Base.size(CM::CartanMatrix)
  return size(CM.cm)
end

function Base.size(CM::CartanMatrix, d::Int)
  return size(CM.cm, d)
end

function Base.length(CM::CartanMatrix)
  return length(CM.cm)
end

function Base.getindex(CM::CartanMatrix, i::Int)
  return getindex(CM.cm,i)
end

function Base.getindex(CM::CartanMatrix, i::Int, j::Int)
  return getindex(CM.cm, i, j)
end

function Base.setindex!(CM::CartanMatrix, x::fmpz, i::Int, j::Int)
  return setindex!(CM.cm,x,i,j)
end


"""
    is_cartan_matrix(C::CartanMatrix)

returns true iff C is a *(generalized)* **Cartan matrix**.
"""
function is_cartan_matrix(C::CartanMatrix)
    #is square
    if size(C,1) != size(C,2)
        return false
    end
    #main diagonal = 2
    for i = 1:size(C,1)
        if C[i,i] != 2
            return false
        end
    end
    #C[i,j]=0 ⇒ C[j,i]=0  and  C[i,j]≤0
    for i = 1:size(C,1)
        for j = 1:i-1
            if C[i,j]>0 || C[j,i]>0 || (C[i,j]==0) ⊻ (C[j,i]==0)
                return false
            end
        end
    end
    return true
end

"""
    CartanMatrix(type::String)

generates the CartanMatrix defined by ``type`` which should be of the following form:
"LN~" or "LN" with L ∈ {A,B,C,D,E,F,G} and N ∈ ℕ.

```
CartanMatrix("LN~")
CartanMatrix("LN")
```
returns ``\\tilde{L_N}`` or ``L_N`` respectively.

for example you could call:
```
CartanMatrix("A12~")
```
"""
function CartanMatrix(type::String)
    #check if the input is in the correct format
    if length(type)<2 || !isletter(type[1]) || (!isdigit(type[end]) && type[end]!='~') || type[end]=='~' && length(type)==2
        throw(ArgumentError("type has to be of the Form: \"LetterNumber\" or \"LetterNumber~\" "))
    end
    for i = 2:length(type)-1
        if !isdigit(type[i])
            throw(ArgumentError("type has to be of the Form: \"LetterNumber\" or \"LetterNumber~\" "))
        end
    end

    tilde = type[end]=='~'
    return CartanMatrix(type[1],parse(Int,type[2:end-tilde]),tilde)
end


"""
    CartanMatrix(type::Char, dim::Int, tilde=false::Bool)

generates the CartanMatrix ``\\tilde{type_{dim}}`` if tilde = true and ``type_{dim}`` otherwise

for example you could call:
```
CartanMatrix('A',12,true)
CartanMatrix('C',7)
```
"""
function CartanMatrix(type::Char, dim::Int, tilde=false::Bool)
    if type == 'A'
        dim >= 1 || throw(ArgumentError("dim ≥ 1 required for type = A"*(tilde ? "~" : "")))
        if tilde
            dim += 1
        end
        CM = diagonal_matrix(ZZ(2), dim)
        CM[2,1] = -1
        for j = 2:dim-1
            CM[j-1,j] = -1
            CM[j+1,j] = -1
        end
        CM[dim-1,dim] = -1
        if tilde
            CM[1,dim] = -1
            CM[dim,1] = -1
        end
        return CartanMatrix(CM)

    elseif type == 'B'
        dim >= 3 || !tilde || throw(ArgumentError("dim ≥ 3 required for type = B~"))
        dim >=2 || throw(ArgumentError("dim ≥ 2 required for type = B"))

        if dim == 2
            CM = diagonal_matrix(ZZ(2), 2)
            CM[2,1] = -2
            CM[1,2] = -1
            return CartanMatrix(CM)
        end

        if tilde
            dim += 1
        end
        CM = diagonal_matrix(ZZ(2), dim)

        if tilde
            CM[3,1] = -1
            CM[1,3] = -1
        else
            CM[2,1] = -1
            CM[1,2] = -1
        end

        CM[3,2] = -1
        for j = 3:dim-2
            CM[j-1,j] = -1
            CM[j+1,j] = -1
        end
        CM[dim-2,dim-1] = -1
        CM[dim,dim-1] = -2
        CM[dim-1,dim] = -1
        return CartanMatrix(CM)

    elseif type == 'C'
        dim >= 2 || !tilde || throw(ArgumentError("dim ≥ 2 required for type = C~"))
        dim >= 3 || tilde || throw(ArgumentError("dim ≥ 3 required for type = C"))
        if tilde
            dim += 1
        end
        CM = diagonal_matrix(ZZ(2), dim)

        if tilde
            CM[2,1] = -2
        else
            CM[2,1] = -1
        end
        for j = 2:dim-1
            CM[j-1,j] = -1
            CM[j+1,j] = -1
        end
        CM[dim-1,dim] = -2

        return CartanMatrix(CM)

    elseif type == 'D'
        dim >= 4 || throw(ArgumentError("dim ≥ 4 required for type = D"*(tilde ? "~" : "")))

        if tilde
            dim += 1
        end
        CM = diagonal_matrix(ZZ(2), dim)

        if tilde
            CM[3,1] = -1
            CM[1,3] = -1
        else
            CM[2,1] = -1
            CM[1,2] = -1
        end

        CM[3,2] = -1
        for j = 3:dim-2
            CM[j-1,j] = -1
            CM[j+1,j] = -1
        end
        CM[dim,dim-2] = -1
        CM[dim-2,dim-1] = -1
        CM[dim-2,dim] = -1
        return CartanMatrix(CM)

    elseif type == 'E'
        dim>=6 && dim <=8 || throw(ArgumentError("6 ≤ dim ≤ 8 required for type = E"*(tilde ? "~" : "")))

        if tilde
            dim += 1
        end
        CM = diagonal_matrix(ZZ(2), dim)

        if tilde && dim==7 #E~6
            CM[5,1] = -1
            CM[1,5] = -1
        elseif tilde && dim==8 #E~7
            CM[dim,1] = -1
            CM[1,dim] = -1
        else
            CM[2,1] = -1
            CM[1,2] = -1
        end

        CM[3,2] = -1
        for j = 3:dim-3
            CM[j-1,j] = -1
            CM[j+1,j] = -1
        end
        CM[dim-1,dim-3] = -1
        CM[dim-3,dim-2] = -1
        CM[dim-3,dim-1] = -1
        CM[dim,dim-1] = -1
        CM[dim-1,dim] = -1
        return CartanMatrix(CM)

    elseif type == 'F'
        dim == 4 || throw(ArgumentError(" dim=4  required for type = F"*(tilde ? "~" : "")))

        if !tilde
            CM = diagonal_matrix(ZZ(2), dim)
            CM[2,1] = -1
            CM[1,2] = -1
            CM[3,2] = -2
            CM[2,3] = -1
            CM[4,3] = -1
            CM[3,4] = -1
        else
            CM = diagonal_matrix(ZZ(2), dim+1)
            CM[2,1] = -1
            CM[1,2] = -1
            CM[3,2] = -1
            CM[2,3] = -1
            CM[4,3] = -2
            CM[3,4] = -1
            CM[5,4] = -1
            CM[4,5] = -1
        end
        return CartanMatrix(CM)

    elseif type == 'G'
        dim == 2 || throw(ArgumentError(" dim=2  required for type = G"*(tilde ? "~" : "")))

        if tilde
            CM = diagonal_matrix(ZZ(2), 3)
            CM[2,1] = -1
            CM[1,2] = -1
            CM[3,2] = -3
            CM[2,3] = -1
        else
            CM = diagonal_matrix(ZZ(2), 2)
            CM[2,1] = -1
            CM[1,2] = -3
        end
        return CartanMatrix(CM)
    end
    throw(ArgumentError("type has to be either \'A\', \'B\', \'C\', \'D\', \'E\', \'F\' or \'G\'"))
end


"""
    CartanMatrix(types::Array{String,1})

generates the **Cartan block matrix** defined by ``types`` whose elements should be of the following form:
"LN~" or "LN" with L ∈ {A,B,C,D,E,F,G} and N ∈ ℕ.

for example you could call:
```
CartanMatrix( [ "A12~" , "B7" , "C9~" ] )
```
"""
function CartanMatrix(types::Array{String,1})
    if isempty(types)
        throw(ArgumentError("types can't be empty"))
    end
    for type in types
        if length(type)<2 || !isletter(type[1]) || (!isdigit(type[end]) && type[end]!='~') || type[end]=='~' && length(type)==2
            throw(ArgumentError("invalid input: \""*type*" \"  types elements have to be of the form: \"LetterNumber\" or \"LetterNumber~\" "))
        end
        for i = 2:length(type)-1
            if !isdigit(type[i])
                throw(ArgumentError("invalid input: \""*type*" \"  types elements have to be of the form: \"LetterNumber\" or \"LetterNumber~\" "))
            end
        end
    end

    L = Array{Char,1}(undef,length(types))  #the types 'A',...,'G'
    N = zeros(Int, length(types))           #the dimensions _n
    tilde = falses(length(types))
    for i = 1:length(types)
        L[i] = types[i][1]
        tilde[i] = types[i][end]=='~'
        N[i] = parse(Int, types[i][2:end-tilde[i]])
    end
    return CartanMatrix(L,N,tilde)
end


"""
    CartanMatrix(types::Array{Char,1}, dims::Array{Int,1}, tildes::BitArray{1})

generates the **Cartan block matrix** ``types[1]_{dims[1]} ✖ ̃\\tilde{types[2]_{dims[2]}} …`` if for example ``tildes[1]=true, tildes[2]=false, …``

for example you could call:
```
CartanMatrix( ["A", "B", "C"], [12, 7, 9], [true, false, true] )
```
which would return the same as
```
CartanMatrix( [ "A12~" , "B7" , "C9~" ] )
```
"""
function CartanMatrix(types::Array{Char,1}, dims::Array{Int,1}, tildes::BitArray{1})
    length(types)==length(dims) && length(dims)==length(tildes) || throw(ArgumentError("types, dims and tilde have to be of equal lengths"))

    CM = diagonal_matrix(ZZ(2), sum(dims)+sum(tildes))
    c = 0 # the offset
    for k = 1:length(types)

        type = types[k]
        dim = dims[k]
        tilde = tildes[k]

        if type == 'A'
            dim >= 1 || throw(ArgumentError("dim ≥ 1 required for type = A"*(tilde ? "~" : "")))
            if tilde
                dim += 1
            end
            CM[2+c,1+c] = -1
            for j = 2+c:dim-1+c
                CM[j-1,j] = -1
                CM[j+1,j] = -1
            end
            CM[dim-1+c,dim+c] = -1
            if tilde
                CM[1+c,dim+c] = -1
                CM[dim+c,1+c] = -1
            end

        elseif type == 'B'
            dim >= 3 || !tilde || throw(ArgumentError("dim ≥ 3 required for type = B~"))
            dim >=2 || throw(ArgumentError("dim ≥ 2 required for type = B"))

            if dim == 2
                CM[2+c,1+c] = -2
                CM[1+c,2+c] = -1
                return CartanMatrix(CM)
            end

            if tilde
                dim += 1
            end

            if tilde
                CM[3+c,1+c] = -1
                CM[1+c,3+c] = -1
            else
                CM[2+c,1+c] = -1
                CM[1+c,2+c] = -1
            end

            CM[3+c,2+c] = -1
            for j = 3+c:dim-2+c
                CM[j-1,j] = -1
                CM[j+1,j] = -1
            end
            CM[dim-2+c,dim-1+c] = -1
            CM[dim+c,dim-1+c] = -2
            CM[dim-1+c,dim+c] = -1

        elseif type=='C'
            dim >= 2 || !tilde || throw(ArgumentError("dim ≥ 2 required for type = C~"))
            dim >= 3 || tilde || throw(ArgumentError("dim ≥ 3 required for type = C"))
            if tilde
                dim += 1
            end

            if tilde
                CM[2+c,1+c] = -2
            else
                CM[2+c,1+c] = -1
            end
            for j = 2+c:dim-1+c
                CM[j-1,j] = -1
                CM[j+1,j] = -1
            end
            CM[dim-1+c,dim+c] = -2

            return CartanMatrix(CM)

        elseif type == 'D'
            dim >= 4 || throw(ArgumentError("dim ≥ 4 required for type = D"*(tilde ? "~" : "")))

            if tilde
                dim += 1
                CM[3+c,1+c] = -1
                CM[1+c,3+c] = -1
            else
                CM[2+c,1+c] = -1
                CM[1+c,2+c] = -1
            end

            CM[3+c,2+c] = -1
            for j = 3+c:dim-2+c
                CM[j-1,j] = -1
                CM[j+1,j] = -1
            end
            CM[dim+c,dim-2+c] = -1
            CM[dim-2+c,dim-1+c] = -1
            CM[dim-2+c,dim+c] = -1

        elseif type == 'E'
            dim>=6 && dim <=8 || throw(ArgumentError("6 ≤ dim ≤ 8 required for type = E"*(tilde ? "~" : "")))

            if tilde
                dim += 1
            end

            if tilde && dim==7 #E~6
                CM[5+c,1+c] = -1
                CM[1+c,5+c] = -1
            elseif tilde && dim==8 #E~7
                CM[dim+c,1+c] = -1
                CM[1+c,dim+c] = -1
            else
                CM[2+c,1+c] = -1
                CM[1+c,2+c] = -1
            end

            CM[3+c,2+c] = -1
            for j = 3+c:dim-3+c
                CM[j-1,j] = -1
                CM[j+1,j] = -1
            end
            CM[dim-1+c,dim-3+c] = -1
            CM[dim-3+c,dim-2+c] = -1
            CM[dim-3+c,dim-1+c] = -1
            CM[dim+c,dim-1+c] = -1
            CM[dim-1+c,dim+c] = -1

        elseif type == 'F'
            dim == 4 || throw(ArgumentError(" dim=4  required for type = F"*(tilde ? "~" : "")))

            CM[2+c,1+c] = -1
            CM[1+c,2+c] = -1
            if !tilde
                CM[3+c,2+c] = -2
                CM[2+c,3+c] = -1
                CM[4+c,3+c] = -1
                CM[3+c,4+c] = -1
            else
                CM[3+c,2+c] = -1
                CM[2+c,3+c] = -1
                CM[4+c,3+c] = -2
                CM[3+c,4+c] = -1
                CM[5+c,4+c] = -1
                CM[4+c,5+c] = -1
            end

        elseif type == 'G'
            dim == 2 || throw(ArgumentError(" dim=2  required for type == G"*(tilde ? "~" : "")))

            CM[2+c,1+c] = -1
            if tilde
                CM[1+c,2+c] = -1
                CM[3+c,2+c] = -3
                CM[2+c,3+c] = -1
            else
                CM[1+c,2+c] = -3
            end

        else
            throw(ArgumentError("type has to be either \'A\', \'B\', \'C\', \'D\', \'E\', \'F\' or \'G\'"))
        end
        c += dims[k] + tilde
    end
    return CartanMatrix(CM)
end
