#############################################################################
##
##  SimplicialSurface package
##
##  Copyright 2012-2025
##    Markus Baumeister, RWTH Aachen University
##    Alice Niemeyer, RWTH Aachen University 
##
## Licensed under the GPL 3 or later.
##
#############################################################################

#! @Chapter Constructing Families of Simplicial Surfaces
#! @ChapterLabel ConstructingFamilies
#! @Section CombinatorialEmbeddings
#! @SectionLabel LabelEmbeddings
#! @BeginGroup Reembeddings
#! @Description
#! The method <K>ReembeddingsOfSimplicialSphere</K> computes all edge-face equivalent simplicial surfaces
#! of the given vertex-faithful simplicial sphere <K>surf</K> with the given genus <K>g</K> if these
#! simplicial surfaces are orientable or not is given by <K>oriented</K>. Note that two simplicial surfaces are edge-face equivalent
#! if the corresponding face graphs are isomorphic (see <Ref Subsect="FaceGraph"/> for a definition of the face graph).
#! The method <K>ReembeddingsOfDigraph</K> computes all simplicial surfaces with the given genus <K>g</K>  and if these
#! simplicial surfaces are orientable or not is given by <K>oriented</K> that have <K>digraph</K> as their face graph.
#! We call this a re-embedding of a digraph or a simplicial sphere.
#!
#! Note that, non-orientable surfaces of genus one are projective planes, orientable surfaces of genus one are tori
#! and non-orientable surfaces of genus two are Klein bottles.
#!
#! For example, consider the complete graph on four vertices:
#! @BeginExampleSession
#! gap> digraph:=CompleteDigraph(4);;
#! gap> ReembeddingsOfDigraph(digraph,1,false);
#! [ simplicial surface (3 vertices, 6 edges, and 4 faces) ]
#! gap> ReembeddingsOfDigraph(digraph,1,true);
#! [ ]
#! gap> ReembeddingsOfDigraph(digraph,2,false);
#! [ ]
#! @EndExampleSession
#! So the complete graph on four vertices has exactly one re-embedding on a projective plane but no
#! re-embedding on the torus or the Klein bottle. Note that the complete graph on four vertices is the face graph
#! of the tetrahedron.
#! The octahedron has for example no edge-face equivalent projective plane but three edge-face equivalent tori
#! and two edge-face equivalent Klein bottles.
#! @BeginExampleSession
#! gap> oct:=Octahedron();;
#! gap> ReembeddingsOfSimplicialSphere(Octahedron(),1,false);
#! [ ]
#! gap> ReembeddingsOfSimplicialSphere(Octahedron(),1,true);
#! [ simplicial surface (4 vertices, 12 edges, and 8 faces), 
#!   simplicial surface (4 vertices, 12 edges, and 8 faces),
#!   simplicial surface (4 vertices, 12 edges, and 8 faces) ]
#! gap> ReembeddingsOfSimplicialSphere(Octahedron(),2,false);
#! [ simplicial surface (4 vertices, 12 edges, and 8 faces),
#!   simplicial surface (4 vertices, 12 edges, and 8 faces) ]
#! @EndExampleSession
#! 
#! @Arguments digraph, g, oriented
#! @Returns a list
DeclareOperation( "ReembeddingsOfDigraph", [IsDigraph, IsInt, IsBool]);
#! @Arguments  surf, g, oriented
#! @Returns a list
DeclareOperation( "ReembeddingsOfSimplicialSphere", [IsSimplicialSurface, IsInt, IsBool]);
#! @EndGroup