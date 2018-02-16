#############################################################################
##
##  SimplicialSurface package
##
##  Copyright 2012-2016
##    Markus Baumeister, RWTH Aachen University
##    Alice Niemeyer, RWTH Aachen University 
##
## Licensed under the GPL 3 or later.
##
#############################################################################

## This chapter contains many diverse aspects of polygonal complexes.
## The current order may not be optimal, depending on what the future holds

#######
## This has to be after the incidence chapter since it heavily relies on it.
## Since it consists of disconnected ideas it is no big issue if it comes
## after the constuctors-chapter that inclines the reader to skipping.
#######

#! @Chapter Properties of surfaces and complexes
#! @ChapterLabel Properties
#! 
#! TODO Introduction
#!
#! We will showcase these properties on several examples. One of them is the
#! <E>five-star</E>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!     \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> fiveStar := SimplicialSurfaceByVerticesInFaces( [1,2,3,5,7,11], 5,
#! >                [ [1,2,3], [1,3,5], [1,5,7], [1,7,11], [1,2,11] ] );;
#! @EndExampleSession
#TODO projective plane on four faces?

#! @Section Invariants
#! @SectionLabel Properties_Invariants
#!
#! This section collects invariants of polygonal complexes.
#!
#! TODO
#!

#! @Description
#! Return the <E>Euler-characteristic</E> of the given polygonal complex.
#! The Euler-characteristic is computed as
#! @BeginLogSession
#! gap> NumberOfVertices(complex) - NumberOfEdges(complex) + NumberOfFaces(complex);
#! @EndLogSession
#! As an example, consider the five-star that was introduced at the
#! start of chapter <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!      \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> NumberOfVertices(fiveStar);
#! 6
#! gap> NumberOfEdges(fiveStar);
#! 10
#! gap> NumberOfFaces(fiveStar);
#! 5
#! gap> EulerCharacteristic(fiveStar);
#! 1
#! @EndExampleSession
#! 
#! @Returns an integer
#! @Arguments complex
DeclareAttribute( "EulerCharacteristic", IsPolygonalComplex );


#! @Description
#! Check whether the given ramified polygonal surface is <E>closed</E>.
#! A ramified surface is closed if every edge is incident to <E>exactly</E> 
#! two
#! faces (whereas a polygonal complex is a ramified polygonal surface if 
#! every edge is incident to <E>at most</E> two faces).
#!
#! For example, the platonic solids are closed.
#! @ExampleSession
#! gap> IsClosedSurface( Octahedron() );
#! true
#! gap> IsClosedSurface( Dodecahedron() );
#! true
#! @EndExampleSession
#! In contrast, the five-star from the start of chapter
#! <Ref Chap="Chapter_Properties"/> is not closed.
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!      \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> IsClosedSurface(fiveStar);
#! false
#! @EndExampleSession
#!
#! @Arguments ramSurf
DeclareProperty( "IsClosedSurface", IsRamifiedPolygonalSurface );
## We can't use IsClosed since this is blocked by the orb-package


#! @Section Degree-based properties and invariants
#! @SectionLabel Properties_Degrees

#TODO there is no good place for degrees, it seems.
# separating them into an own section feels weird, but putting them under 
# vertex properties feels weird as well (since there are methods like 
# InnerVertices etc. that feel too connected to separate them by the degrees..);

#TODO intro
#! This section contains properties and invariants that are based on the
#! degrees of the vertices. We have to distinguish two different definitions
#! for the degree of a vertex - we can either count the number of incident
#! edges of the number of incident faces.
#!
#! These two definitions are distinguished by calling them 
#! <K>EdgeDegreesOfVertices</K> and <K>FaceDegreesOfVertices</K>.
#! 
#TODO explain sorted/unsorted
#TODO mention vertexCounter, edgeCounter


#! @BeginGroup EdgeDegreesOfVertices
#! @Description
#! The method <K>EdgeDegreeOfVertex</K>(<A>complex</A>, <A>vertex</A>) 
#! returns the <E>edge-degree</E> of the given vertex in the given
#! polygonal complex, i.e. the number of incident edges. The NC-version does
#! not check whether <A>vertex</A> is a vertex of <A>complex</A>.
#!
#! The attribute <K>EdgeDegreesOfVertices</K>(<A>complex</A>) collects all of
#! these degrees in a list that is indexed by the vertices, i.e.
#! <K>EdgeDegreesOfVertices</K>(<A>complex</A>)[<A>vertex</A>] = 
#! <K>EdgeDegreeOfVertex</K>(<A>complex</A>, <A>vertex</A>). All other
#! positions of this list are not bound.
#!
#! As an example, consider the five-star from the start of chapter
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!    \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!       \input{Image_FiveTrianglesInCycle.tex}
#!    \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> EdgeDegreeOfVertex( fiveStar, 1 );
#! 5
#! gap> EdgeDegreeOfVertex( fiveStar, 5 );
#! 3
#! gap> EdgeDegreesOfVertices( fiveStar );
#! [ 5, 3, 3,, 3,, 3,,,, 3 ]
#! @EndExampleSession
#!
#! @Returns a list of positive integers
#! @Arguments complex
DeclareAttribute( "EdgeDegreesOfVertices", IsPolygonalComplex );
#! @Returns a positive integer
#! @Arguments complex, vertex
DeclareOperation( "EdgeDegreeOfVertex", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, vertex
DeclareOperation( "EdgeDegreeOfVertexNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup


#! @BeginGroup FaceDegreesOfVertices
#! @Description
#! The method <K>FaceDegreeOfVertex</K>(<A>complex</A>, <A>vertex</A>) 
#! returns the <E>face-degree</E> of the given vertex in the given
#! polygonal complex, i.e. the number of incident faces. The NC-version does
#! not check whether <A>vertex</A> is a vertex of <A>complex</A>.
#!
#! The attribute <K>FaceDegreesOfVertices</K>(<A>complex</A>) collects all of
#! these degrees in a list that is indexed by the vertices, i.e.
#! <K>FaceDegreesOfVertices</K>(<A>complex</A>)[<A>vertex</A>] = 
#! <K>FaceDegreeOfVertex</K>(<A>complex</A>, <A>vertex</A>). All other
#! positions of this list are not bound.
#!
#! As an example, consider the five-star from the start of chapter
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!    \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!       \input{Image_FiveTrianglesInCycle.tex}
#!    \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> FaceDegreeOfVertex( fiveStar, 1 );
#! 5
#! gap> FaceDegreeOfVertex( fiveStar, 5 );
#! 2
#! gap> FaceDegreesOfVertices( fiveStar );
#! [ 5, 2, 2,, 2,, 2,,,, 2 ]
#! @EndExampleSession
#!
#! @Returns a list of positive integers
#! @Arguments complex
DeclareAttribute( "FaceDegreesOfVertices", IsPolygonalComplex );
#! @Returns a positive integer
#! @Arguments complex, vertex
DeclareOperation( "FaceDegreeOfVertex", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, vertex
DeclareOperation( "FaceDegreeOfVertexNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup




#! @BeginGroup VertexCounter
#! @Description
#! Return the <E>vertex counter</E> of the given polygonal complex.
#! The vertex counter is a list that counts how many vertices are incident
#! to how many faces. It is a list of pairs <E>[degree, number]</E>, where
#! <E>number</E> counts the number of vertices with exactly <E>degree</E>
#! incident faces.
#!
#! As an example, consider the five-star from the start of chapter
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!      \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> List( FacesOfVertices(fiveStar), Size );
#! [ 5, 2, 2,, 2,, 2,,,, 2 ]
#! gap> VertexCounter(fiveStar);
#! [ [ 2, 5 ], [ 5, 1 ] ]
#! @EndExampleSession
#!
#! @Returns a list of pairs of positive integers
#! @Arguments complex
DeclareAttribute( "VertexCounter", IsPolygonalComplex );
#! @EndGroup


#! @Description
#! Return the <E>edge counter</E> of the given polygonal complex.
#! The edge counter is a list of pairs <E>[degreeList, number]</E>,
#! where <E>number</E> counts the number of edges whose vertices
#! are incident to <E>degreeList[1]</E> and <E>degreeList[2]</E> faces,
#! respectively. The list <E>degreeList</E> is always sorted but may
#! contain duplicates.
#!
#! As an example, consider the five-star from the start of chapter
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!      \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> EdgeCounter(fiveStar);
#! [ [ [ 2, 2 ], 5 ], [ [ 2, 5 ], 5 ] ]
#! @EndExampleSession
#!
#! @Returns a list of pairs
#! @Arguments complex
DeclareAttribute( "EdgeCounter", IsPolygonalComplex );


#! @Description
#! Return the <E>face counter</E> of the given polygonal complex.
#! The face counter is a list of pairs <E>[degreeList, number]</E>,
#! where <E>number</E> counts the number of faces whose vertes degrees
#! match <E>degreeList</E>, i.e. for every vertex there is exactly one
#! entry of <E>degreeList</E> such that the vertex is incident this 
#! number of faces.
#!
#! The <E>degreeList</E> is always sorted but may contain duplicates.
#!
#! As an example, consider the five-star from the start of chapter
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!      \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> FaceCounter(fiveStar);
#! [ [ [ 2, 2, 5 ], 5 ] ]
#! @EndExampleSession
#!
#! @Returns a list of pairs
#! @Arguments complex
DeclareAttribute( "FaceCounter", IsPolygonalComplex );


#! @Section Types of edges
#! @SectionLabel Properties_EdgeTypes
#!
#TODO improve
#! The edges of a polygonal complex (defined in 
#! <Ref Sect="PolygonalStructures_complex"/>) can be in different local
#! positions. This can be seen in the example of the five-star (which was
#! introduced at the start of chapter <Ref Chap="Chapter_Properties"/>):
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!      \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! The edges that are incident to the vertex 1 are different from the other 
#! edges since they lie "inside" the surface. Edges with two incident faces
#! are called <E>inner edges</E> while edges with only one incident face are
#! called <E>boundary edges</E>.
#!
#! For ramified polygonal surfaces, only those two edge types can appear
#! (by definition there are one or two faces incident to each edge). For
#! general polygonal complexes there might appear a third case (more than
#! two faces incident to an edge). This is exemplified in the following
#! example:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[scale=2, vertexPlain=nolabels, edgeStyle=nolabels, faceStyle=nolabels]
#!     \input{Image_ThreeBranchingTriangles.tex}
#!   \end{tikzpicture}
#! </Alt>
#! Edges with more than two incident faces are called <E>ramified edges</E>.
#!

#! @BeginGroup InnerEdges
#! @Description
#! Return the set of all inner edges of the given polygonal complex.
#! An <E>inner edge</E> is an edge that is incident to exactly two faces.
#!
#! The method <K>IsInnerEdge</K> checks whether the given edge is an inner
#! edge of the given polygonal complex. The NC-version does not check whether
#! <A>edge</A> is an edge of <A>complex</A>.
#!
#! Consider the five-star from the start of chapter 
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle, faceStyle]
#!     \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> IsInnerEdge( fiveStar, 4 );
#! true
#! gap> IsInnerEdge( fiveStar, 10 );
#! false
#! gap> InnerEdges( fiveStar );
#! [ 1, 2, 3, 4, 5 ]
#! @EndExampleSession
#!
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "InnerEdges", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, edge
DeclareOperation( "IsInnerEdge", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, edge
DeclareOperation( "IsInnerEdgeNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup


#! @BeginGroup BoundaryEdges
#! @Description
#! Return the set of all boundary edges of the given polygonal complex.
#! A <E>boundary edge</E> is an edge that is incident to exactly one face.
#!
#! The method <K>IsBoundaryEdge</K> checks whether the given edge is a 
#! boundary
#! edge of the given polygonal complex. The NC-version does not check whether
#! <A>edge</A> is an edge of <A>complex</A>.
#!
#! Consider the five-star from the start of chapter 
#! <Ref Chap="Chapter_Properties"/>:
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle, faceStyle]
#!     \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! @ExampleSession
#! gap> IsBoundaryEdge( fiveStar, 4 );
#! false
#! gap> IsBoundaryEdge( fiveStar, 10 );
#! true
#! gap> BoundaryEdges( fiveStar );
#! [ 6, 7, 8, 9, 10 ]
#! @EndExampleSession
#!
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "BoundaryEdges", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, edge
DeclareOperation( "IsBoundaryEdge", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, edge
DeclareOperation( "IsBoundaryEdgeNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup

#! @BeginGroup RamifiedEdges
#! @Description
#! Return the set of all ramified edges of the given polygonal complex.
#! A <E>ramified edge</E> is an edge that is incident to at least three faces.
#!
#! The method <K>IsRamifiedEdge</K> checks whether the given edge is a 
#! ramified
#! edge of the given polygonal complex. The NC-version does not check whether
#! <A>edge</A> is an edge of <A>complex</A>.
#!
#! TODO example?
#!
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "RamifiedEdges", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, edge
DeclareOperation( "IsRamifiedEdge", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, edge
DeclareOperation( "IsRamifiedEdgeNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup



#! @Section Types of vertices
#! @SectionLabel Properties_VertexTypes
#! 
#TODO improve this description
#! The vertices of a polygonal complex (defined in 
#! <Ref Sect="PolygonalStructures_complex"/>) can be in different local
#! positions. This can be seen in the example of the five-star (which was
#! introduced at the start of chapter <Ref Chap="Chapter_Properties"/>):
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[vertexStyle, edgeStyle=nolabels, faceStyle]
#!     \input{Image_FiveTrianglesInCycle.tex}
#!   \end{tikzpicture}
#! </Alt>
#! The vertex 1 is the only vertex that is completely surrounded by faces. It
#! is called an <E>inner vertex</E> while the other vertices of the five-star
#! are <E>boundary vertices</E>. This classifies all vertices of a polygonal
#! surface.
#!
#! In general there are more than these two possibilities. In the case of 
#! ramified polygonal surfaces (defined in 
#! <Ref Sect="PolygonalStructures_ramified"/>) there can be 
#! <E>ramified vertices</E>:
#! <Alt Only="TikZ">
#!    \begin{tikzpicture}[vertexPlain=nolabels, edgeStyle=nolabels, faceStyle=nolabels]
#!       \input{Image_TwoJoinedTetrahedrons.tex}
#!    \end{tikzpicture}
#! </Alt>
#!
#! For general polygonal complexes (defined in 
#! <Ref Sect="PolygonalStructures_complex"/>) there might be edges that are 
#! incident to more than two faces.
#! <Alt Only="TikZ">
#!   \begin{tikzpicture}[scale=2, vertexPlain=nolabels, edgeStyle=nolabels, faceStyle=nolabels]
#!     \input{Image_ThreeBranchingTriangles.tex}
#!   \end{tikzpicture}
#! </Alt>
#! Vertices that are incident to such an edge are called 
#! <E>chaotic vertices</E>.

#! @BeginGroup InnerVertices
#! @Description
#! Return the set of all inner vertices. 
#! 
#! In a polygonal surface a vertex is
#! an inner vertex if and only if every incident edge is incident to exactly
#! two faces (that is, if it only incident to inner edges 
#! (<Ref Subsect="InnerEdges"/>)).
#!
#! In general a vertex is an inner vertex if and only if there is exactly
#! one closed edge-face-path around it (compare section 
#! <Ref Sect="Section_Access_OrderedVertexAccess"/> for the definition of
#! edge-face-paths).
#!
#! The method <K>IsInnerVertex</K> checks whether the given vertex is an inner
#! vertex of the given polygonal complex. The NC-version does not check whether
#! <A>vertex</A> is an vertex of <A>complex</A>.
#!
#! TODO example
#! 
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "InnerVertices", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, vertex
DeclareOperation( "IsInnerVertex", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, vertex
DeclareOperation( "IsInnerVertexNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup

#! @BeginGroup BoundaryVertices
#! @Description
#! Return the set of all boundary vertices.
#!
#! In a polygonal surface a vertex is a boundary vertex if and only if it
#! is incident to one edge that is incident to only one face (if it is 
#! incident to a boundary edge (<Ref Subsect="BoundaryEdges"/>)).
#!
#! In general a vertex is a boundary vertex if and only if there is exactly
#! one non-closed edge-face-path around it (compare section
#! <Ref Sect="Section_Access_OrderedVertexAccess"/> for the definition of
#! edge-face-paths).
#!
#! The method <K>IsBoundaryVertex</K> checks whether the given vertex is a 
#! boundary
#! vertex of the given polygonal complex. The NC-version does not check whether
#! <A>vertex</A> is an vertex of <A>complex</A>.
#!
#! TODO example
#! 
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "BoundaryVertices", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, vertex
DeclareOperation( "IsBoundaryVertex", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, vertex
DeclareOperation( "IsBoundaryVertexNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup

#! @BeginGroup RamifiedVertices
#! @Description
#! Return the set of all ramified vertices.
#!
#! A vertex is ramified if and only if there is a well-defined
#! edge-face-path partition around it (compare 
#! <Ref Subsect="UmbrellaPartitionsOfVertices"/>) and there are at least two
#! elements in this partition.
#!
#! The method <K>IsRamifiedVertex</K> checks whether the given vertex is a
#! ramified
#! vertex of the given polygonal complex. The NC-version does not check whether
#! <A>vertex</A> is an vertex of <A>complex</A>.
#!
#! TODO example
#! 
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "RamifiedVertices", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, vertex
DeclareOperation( "IsRamifiedVertex", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, vertex
DeclareOperation( "IsRamifiedVertexNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup

#! @BeginGroup ChaoticVertices
#! @Description
#! Return the set of all chaotic vertices.
#!
#! A vertex is chaotic if and only if it is incident to an edge that is
#! incident to at least three faces. In other words, there is no well-defined
#! edge-face-path partition (<Ref Subsect="UmbrellaPartitionsOfVertices"/>) around 
#! a chaotic vertex.
#!
#! The method <K>IsChaoticVertex</K> checks whether the given vertex is a 
#! chaotic
#! vertex of the given polygonal complex. The NC-version does not check whether
#! <A>vertex</A> is an vertex of <A>complex</A>.
#!
#! TODO example
#! 
#! @Returns a set of positive integers
#! @Arguments complex
DeclareAttribute( "ChaoticVertices", IsPolygonalComplex );
#! @Returns true or false
#! @Arguments complex, vertex
DeclareOperation( "IsChaoticVertex", [IsPolygonalComplex, IsPosInt] );
#! @Arguments complex, vertex
DeclareOperation( "IsChaoticVertexNC", [IsPolygonalComplex, IsPosInt] );
#! @EndGroup

