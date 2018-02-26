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


# We define a generic representation for polygonal complexes
DeclareRepresentation("IsGenericPolygonalComplexRep", 
    IsPolygonalComplex and IsAttributeStoringRep, []);

# Define a generic type
BindGlobal( "PolygonalComplexType", 
    NewType( PolygonalComplexFamily, IsGenericPolygonalComplexRep ));



##
## Check whether a polygonal complex is a triangular complex.
##
__SIMPLICIAL_AddPolygonalAttribute( IsTriangularComplex );
InstallMethod( IsTriangularComplex, "for a polygonal complex that has EdgesOfFaces",
    [ IsPolygonalComplex and HasEdgesOfFaces ],
    function( complex )
        local edgeSize, e;

        edgeSize := List(Faces(complex), f -> Length(EdgesOfFaces(complex)[f]));
        for e in edgeSize do
            if e <> 3 then
                return false;
            fi;
        od;
        return true;
    end
);
AddPropertyIncidence( SIMPLICIAL_ATTRIBUTE_SCHEDULER, "IsTriangularComplex",
    "EdgesOfFaces");


##
## Check whether a polygonal complex is a ramified polygonal surface.
##
__SIMPLICIAL_AddPolygonalAttribute( IsRamifiedPolygonalSurface );
InstallMethod( IsRamifiedPolygonalSurface, 
    "for a polygonal complex that has Edges and FacesOfEdges",
    [ IsPolygonalComplex and HasFacesOfEdges and HasEdges ],
    function( complex )
        local faceSize, f;
        
        faceSize := List( Edges(complex), e -> Length(FacesOfEdges(complex)[e]) );
        for f in faceSize do
            if f > 2 then
                return false;
            fi;
        od;
        return true;
    end
);
AddPropertyIncidence( SIMPLICIAL_ATTRIBUTE_SCHEDULER, 
    "IsRamifiedPolygonalSurface", ["Edges", "FacesOfEdges"] );


##
## Check whether a ramified polygonal surface is a polygonal surface
##
__SIMPLICIAL_AddPolygonalAttribute( IsPolygonalSurface );
InstallMethod( IsPolygonalSurface, 
    "for a ramified polygonal surface with UmbrellaPartitionsOfVertices and Vertices",
    [ IsRamifiedPolygonalSurface and HasUmbrellaPartitionsOfVertices and HasVerticesAttributeOfPolygonalComplex],
    function( ramSurf )
        local paths, pathSize, s;

        paths := UmbrellaPartitionsOfVertices(ramSurf);
        pathSize := List( VerticesAttributeOfPolygonalComplex(ramSurf), v -> Length(paths[v]) );
        for s in pathSize do
            if s <> 1 then
                return false;
            fi;
        od;
        return true;
    end
);
AddPropertyIncidence( SIMPLICIAL_ATTRIBUTE_SCHEDULER, "IsPolygonalSurface",
    ["IsRamifiedPolygonalSurface", "UmbrellaPartitionsOfVertices", "VerticesAttributeOfPolygonalComplex"] );
InstallImmediateMethod( IsPolygonalSurface,
    "for a polygonal complex that is no ramified polygonal surface",
    IsPolygonalComplex and HasIsRamifiedPolygonalSurface, 0,
    function(complex)
        if not IsRamifiedPolygonalSurface(complex) then
            return false;
        fi;
        TryNextMethod();
    end
);
