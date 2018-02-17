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


#######################################
##
##      Start splitting methods
##


## Splitting edges
InstallOtherMethod( SplitEdge, "for a polygonal complex and an edge",
    [IsPolygonalComplex, IsPosInt],
    function(complex, edge)
        if not edge in Edges(complex) then
            Error(Concatenation("SplitEdge: Given edge ", edge, 
                " is not one of the edges ", Edges(complex), 
                " of the given polygonal complex." ) );
        fi;
        return SplitEdgeNC(complex, edge);
    end
);
InstallOtherMethod( SplitEdgeNC, "for a polygonal complex and an edge",
    [IsPolygonalComplex, IsPosInt],
    function(complex, edge)
        local nrIncFaces;

        nrIncFaces := Size(FacesOfEdges(complex)[edge]);
        if nrIncFaces = 1 then
            return SplitEdgeNC(complex, edge, [edge]);
        else
            return SplitEdgeNC(complex, edge, 
                List([1..nrIncFaces], i -> Maximum(Edges(complex))+i));
        fi;
    end
);

InstallMethod( SplitEdge, "for a polygonal complex, an edge and a list",
    [IsPolygonalComplex, IsPosInt, IsList],
    function(complex, edge, newEdgeLabels)
        local intersect;

        if not edge in Edges(complex) then
            Error(Concatenation("SplitEdge: Given edge ", edge, 
                " is not one of the edges ", Edges(complex), 
                " of the given polygonal complex." ) );
        fi;

        if ForAny(newEdgeLabels, e -> not IsPosInt(e)) then
            Error(Concatenation(
                "SplitEdge: The new edge labels have to be positive integers, but are ", 
                newEdgeLabels, "."));
        fi;

        if Size( Set(newEdgeLabels) ) <> Size(FacesOfEdges(complex)[edge]) then
            Error(Concatenation(
                "SplitEdge: The number of new edge labels has to be equal to the number of incident faces."
            ));
        fi;

        intersect := Intersection( Edges(complex), newEdgeLabels );
        if Size(intersect) = 0 or (Size(intersect)=1 and intersect[1] = edge) then
            return SplitEdgeNC(complex, edge, newEdgeLabels);
        else
            Error(Concatenation("SplitEdge: The new edge labels ", 
                newEdgeLabels, 
                " have to be disjoint from the existing edge labels ", 
                Edges(complex)));
        fi;
    end
);
InstallMethod( SplitEdgeNC, "for a polygonal complex, an edge and a list",
    [IsPolygonalComplex, IsPosInt, IsList],
    function(complex, edge, newEdgeLabels)
        local newVertsOfEdges, newFacesOfEdges, verts, l, incFaces, obj, i;

        newEdgeLabels := Set(newEdgeLabels);

        newVertsOfEdges := ShallowCopy( VerticesOfEdges(complex) );
        newFacesOfEdges := ShallowCopy( FacesOfEdges(complex) );
        verts := newVertsOfEdges[edge];
        Unbind(newVertsOfEdges[edge]);
        for l in newEdgeLabels do
            newVertsOfEdges[l] := verts;
        od;

        incFaces := newFacesOfEdges[edge];
        Unbind(newFacesOfEdges[edge]);
        for i in [1..Size(incFaces)] do
            newFacesOfEdges[newEdgeLabels[i]] := [incFaces[i]];
        od;

        obj := Objectify( PolygonalComplexType, rec() );
        SetVerticesOfEdges(obj, newVertsOfEdges);
        SetFacesOfEdges(obj, newFacesOfEdges);

        return [obj, newEdgeLabels];
    end
);


## Splitting vertices
BindGlobal( "__SIMPLICIAL_ConnectedStarComponents",
    function(complex, vertex)
        local faces, edges, edgeOfFaces, f, comp, conn;

        faces := FacesOfVertices(complex)[vertex];
        edges := EdgesOfVertices(complex)[vertex];
        edgeOfFaces := [];
        for f in faces do
            edgeOfFaces[f] := Intersection( edges, EdgesOfFaces(complex)[f] );
        od;

        comp := [];
        while Size(faces) > 0 do
            conn := __SIMPLICIAL_AbstractConnectedComponent( 
                faces, edgeOfFaces, faces[1] );
            Add( comp, [ conn, Union(edgeOfFaces{conn}) ] );
            faces := Difference(faces, conn);
        od;

        return comp;
    end
);
InstallOtherMethod( SplitVertex, "for a polygonal complex and a vertex",
    [IsPolygonalComplex, IsPosInt],
    function(complex, vertex)
        if not vertex in Vertices(complex) then
            Error(Concatenation("SplitVertex: Given vertex ", vertex, 
                " is not one of the vertices ", Vertices(complex), 
                " of the given polygonal complex." ) );
        fi;
        return SplitVertexNC(complex, vertex);
    end
);
InstallOtherMethod( SplitVertexNC, "for a polygonal complex and a vertex",
    [IsPolygonalComplex, IsPosInt],
    function(complex, vertex)
        local nrIncStars;

        nrIncStars := Size(__SIMPLICIAL_ConnectedStarComponents(complex, vertex));
        if nrIncStars = 1 then
            return SplitVertexNC(complex, vertex, [vertex]);
        else
            return SplitVertexNC(complex, vertex, 
                List([1..nrIncStars], i -> Maximum(Vertices(complex))+i));
        fi;
    end
);

InstallMethod( SplitVertex, "for a polygonal complex, a vertex and a list",
    [IsPolygonalComplex, IsPosInt, IsList],
    function(complex, vertex, newVertexLabels)
        local intersect;

        if not vertex in Vertices(complex) then
            Error(Concatenation("SplitVertex: Given vertex ", vertex, 
                " is not one of the vertices ", Vertices(complex), 
                " of the given polygonal complex." ) );
        fi;

        if ForAny(newVertexLabels, v -> not IsPosInt(v)) then
            Error(Concatenation(
                "SplitVertex: The new vertex labels have to be positive integers, but are ", 
                newVertexLabels, "."));
        fi;

        if Size( Set(newVertexLabels) ) <> Size(__SIMPLICIAL_ConnectedStarComponents(complex, vertex)) then
            Error(Concatenation(
                "SplitVertex: The number of new vertex labels has to be equal to the number of incident stars.TODO"
            ));
        fi;

        intersect := Intersection( Vertices(complex), newVertexLabels );
        if Size(intersect) = 0 or (Size(intersect)=1 and intersect[1] = vertex) then
            return SplitVertexNC(complex, vertex, newVertexLabels);
        else
            Error(Concatenation("SplitVertex: The new vertex labels ", 
                newVertexLabels, 
                " have to be disjoint from the existing vertex labels ", 
                Vertices(complex)));
        fi;
    end
);
InstallMethod( SplitVertexNC, "for a polygonal complex, a vertex and a list",
    [IsPolygonalComplex, IsPosInt, IsList],
    function(complex, vertex, newVertexLabels)
        local newEdgesOfVertices, starComp, i, obj;

        newEdgesOfVertices := ShallowCopy(EdgesOfVertices(complex));
        starComp := __SIMPLICIAL_ConnectedStarComponents(complex, vertex);
        Unbind(newEdgesOfVertices[vertex]);
        for i in [1..Size(newVertexLabels)] do
            newEdgesOfVertices[newVertexLabels[i]] := starComp[i][2];
        od;

        obj := Objectify( PolygonalComplexType, rec() );
        SetEdgesOfVertices(obj, newEdgesOfVertices);
        SetEdgesOfFaces(obj, EdgesOfFaces(complex));
        return [obj, newVertexLabels];
    end
);

## Splitting vertex-edge-paths
BindGlobal( "__SIMPLICIAL_ComputeNewVertexEdgePaths",
    function(oldComplex, vePath, newComplex, labelList)
        local partialPaths, i, newPaths, p, pNew, pOld, newEdge, used, 
            newVertex;

        partialPaths := [ [[],[]] ];
        for i in [1..Size(labelList)] do
            # Try to extend every partial path in as many ways as possible
            if IsEvenInt(i) then
                # We have to add an edge => paths can't start here
                newPaths := [];
                for p in partialPaths do
                    pNew := p[1];
                    pOld := p[2];
                    for newEdge in labelList[i] do
                        if pNew[Size(pNew)] in VerticesOfEdges(newComplex)[newEdge] then
                            Add(newPaths, [ 
                                Concatenation(pNew, [newEdge]), 
                                Concatenation(pOld, [PathAsList(vePath)[i]]) 
                            ] );
                        fi;
                    od;
                od;
                partialPaths := newPaths;
            else
                # We have to add a vertex => paths can start here
                newPaths := [];
                for newVertex in labelList[i] do
                    used := false;
                    for p in partialPaths do
                        pNew := p[1];
                        pOld := p[2];
                        if Size(pNew) = 0 or pNew[Size(pNew)] in EdgesOfVertices(newComplex)[newVertex] then
                            Add(newPaths, [
                                Concatenation(pNew, [newVertex]),
                                Concatenation(pOld, [PathAsList(vePath)[i]])
                            ]);
                            used := true;
                        fi;
                    od;
                    if not used then
                        Add(newPaths, 
                            [ [newVertex], [PathAsList(vePath)[i]] ]);
                    fi;
                od;
                partialPaths := newPaths;
            fi;
        od;

        return newPaths;
    end
);

InstallMethod( SplitVertexEdgePath, 
    "for a polygonal complex and a list of positive integers",
    [IsPolygonalComplex, IsList],
    function(complex, pathAsList)
        local path;

        path := VertexEdgePath(complex, pathAsList);
        if not IsDuplicateFree(path) then
            Error("SplitVertexEdgePath: Given list of vertices and edges has to represent a duplicate-free vertex-edge-path");
        fi;
        return SplitVertexEdgePathNC(complex, path);
    end
);
InstallMethod( SplitVertexEdgePathNC,
    "for a polygonal complex and a list of positive integers",
    [IsPolygonalComplex, IsList],
    function(complex, pathAsList)
        return SplitVertexEdgePathNC(complex, VertexEdgePath(complex, pathAsList));
    end
);

InstallMethod( SplitVertexEdgePath,
    "for a polygonal complex and a duplicate-free vertex-edge-path",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex, vePath)
        if not complex = AssociatedPolygonalComplex(vePath) then
            Error("SplitVertexEdgePath: Given vertex-edge-path has to match the given polygonal complex.");
        fi;
        return SplitVertexEdgePathNC(complex, vePath);
    end
);
RedispatchOnCondition( SplitVertexEdgePath, true, 
    [IsPolygonalComplex, IsVertexEdgePath], [,IsDuplicateFree], 0 );

InstallMethod( SplitVertexEdgePathNC,
    "for a polygonal complex and a duplicate-free vertex-edge-path",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex, vePath)
        local newLabelList, swapComplex, newComplex, i, edgeSplit, 
            vertexSplit, size;

        newLabelList := [];
        swapComplex := complex;
        # Split the edges
        for i in [1..Size(EdgesAsList(vePath))] do
            edgeSplit := SplitEdge(swapComplex, EdgesAsList(vePath)[i]);
            swapComplex := edgeSplit[1];
            newLabelList[2*i] := edgeSplit[2];
        od;
        # Split the vertices
        for i in [1..Size(VerticesAsList(vePath))-1] do
            vertexSplit := SplitVertex(swapComplex, VerticesAsList(vePath)[i]);
            swapComplex := vertexSplit[1];
            newLabelList[2*i-1] := vertexSplit[2];
        od;
        size := Size(VerticesAsList(vePath));
        if IsClosedPath(vePath) then
            # The last vertex has already be splitted!
            newLabelList[2*size-1] := newLabelList[1];
        else
            vertexSplit := SplitVertex(swapComplex, VerticesAsList(vePath)[size]);
            swapComplex := vertexSplit[1];
            newLabelList[2*size-1] := vertexSplit[2];
        fi;
        newComplex := swapComplex;

        return [newComplex, __SIMPLICIAL_ComputeNewVertexEdgePaths(
                    complex,vePath, newComplex, newLabelList)];
    end
);
RedispatchOnCondition( SplitVertexEdgePathNC, true, 
    [IsPolygonalComplex, IsVertexEdgePath], [,IsDuplicateFree], 0 );


#####



InstallMethod( SplitEdgePath, 
    "for a polygonal complex and a list of positive integers",
    [IsPolygonalComplex, IsList],
    function(complex, pathAsList)
        local path;

        path := VertexEdgePath(complex, pathAsList);
        if not IsDuplicateFree(path) then
            Error("SplitEdgePath: Given list of vertices and edges has to represent a duplicate-free vertex-edge-path");
        fi;
        return SplitEdgePathNC(complex, path);
    end
);
InstallMethod( SplitEdgePathNC,
    "for a polygonal complex and a list of positive integers",
    [IsPolygonalComplex, IsList],
    function(complex, pathAsList)
        return SplitEdgePathNC(complex, VertexEdgePath(complex, pathAsList));
    end
);

InstallMethod( SplitEdgePath,
    "for a polygonal complex and a duplicate-free vertex-edge-path",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex, vePath)
        if not complex = AssociatedPolygonalComplex(vePath) then
            Error("SplitEdgePath: Given vertex-edge-path has to match the given polygonal complex.");
        fi;
        return SplitEdgePathNC(complex, vePath);
    end
);
RedispatchOnCondition( SplitEdgePath, true, 
    [IsPolygonalComplex, IsVertexEdgePath], [,IsDuplicateFree], 0 );

InstallMethod( SplitEdgePathNC,
    "for a polygonal complex and a duplicate-free vertex-edge-path",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex, vePath)
        local newLabelList, swapComplex, newComplex, i, edgeSplit, 
            vertexSplit;

        newLabelList := [];
        swapComplex := complex;
        # Split the edges
        for i in [1..Size(EdgesAsList(vePath))] do
            edgeSplit := SplitEdge(swapComplex, EdgesAsList(vePath)[i]);
            swapComplex := edgeSplit[1];
            newLabelList[2*i] := edgeSplit[2];
        od;
        # Split the vertices
        newLabelList[1] := [VerticesAsList(vePath)[1]];
        for i in [2..Size(VerticesAsList(vePath))-1] do
            vertexSplit := SplitVertex(swapComplex, VerticesAsList(vePath)[i]);
            swapComplex := vertexSplit[1];
            newLabelList[2*i-1] := vertexSplit[2];
        od;
        Add(newLabelList, [VerticesAsList(vePath)[Size(VerticesAsList(vePath))]]);
        newComplex := swapComplex;

        return [newComplex, __SIMPLICIAL_ComputeNewVertexEdgePaths(
                    complex,vePath, newComplex, newLabelList)];
    end
);
RedispatchOnCondition( SplitEdgePathNC, true, 
    [IsPolygonalComplex, IsVertexEdgePath], [,IsDuplicateFree], 0 );


##
##      End splitting methods
##
#######################################


#######################################
##
##      Face removal
##
InstallMethod( SubcomplexByFaces, "for a polygonal complex and a set of faces",
    [IsPolygonalComplex, IsSet],
    function(complex, subfaces)
	if not IsSubset( Faces(complex), subfaces ) then
	    Error("SubcomplexByFaces: there are not only faces given.");
	fi;

	return SubcomplexByFacesNC( complex, subfaces );
    end
);
InstallOtherMethod( SubcomplexByFaces, 
    "for a polygonal complex and a list of faces",
    [ IsPolygonalComplex, IsList ],
    function(complex, subfaces)
        return SubcomplexByFaces(complex, Set(subfaces));
    end
);
InstallMethod( SubcomplexByFacesNC, "for a polygonal complex and a set of faces",
    [IsPolygonalComplex, IsSet],
    function(complex, subfaces)
	local subVertices, subEdges, newVerticesOfEdges, newEdgesOfFaces, e, f;


	subEdges := Union( List( subfaces, f -> EdgesOfFaces(complex)[f] ));
	subVertices := Union( List( subEdges, e -> VerticesOfEdges(complex)[e] ) );

	newVerticesOfEdges := [];
	for e in subEdges do
	    newVerticesOfEdges[e] := VerticesOfEdges(complex)[e];
	od;

	newEdgesOfFaces := [];
	for f in subfaces do
	    newEdgesOfFaces[f] := EdgesOfFaces(complex)[f];
	od;

	return PolygonalComplexByDownwardIncidenceNC( subVertices, subEdges,
			subfaces, newVerticesOfEdges, newEdgesOfFaces );
    end
);
InstallOtherMethod( SubcomplexByFacesNC, 
    "for a polygonal complex and a list of faces",
    [ IsPolygonalComplex, IsList ],
    function(complex, subfaces)
        return SubcomplexByFacesNC(complex, Set(subfaces));
    end
);

####

InstallMethod( RemoveFaces, "for a polygonal complex and a set of faces",
    [IsPolygonalComplex, IsSet],
    function(complex, subfaces)
	if not IsSubset( Faces(complex), subfaces ) then
	    Error("RemoveFaces: there are not only faces given.");
	fi;

	return RemoveFacesNC( complex, subfaces );
    end
);
InstallOtherMethod( RemoveFaces, 
    "for a polygonal complex and a list of faces",
    [ IsPolygonalComplex, IsList ],
    function(complex, subfaces)
        return RemoveFaces(complex, Set(subfaces));
    end
);
InstallMethod( RemoveFacesNC, "for a polygonal complex and a set of faces",
    [IsPolygonalComplex, IsSet],
    function(complex, subfaces)
        return SubcomplexByFacesNC(complex, Difference(Faces(complex), subfaces));
    end
);
InstallOtherMethod( RemoveFacesNC, 
    "for a polygonal complex and a list of faces",
    [ IsPolygonalComplex, IsList ],
    function(complex, subfaces)
        return RemoveFacesNC(complex, Set(subfaces));
    end
);

InstallMethod( RemoveFace, "for a polygonal complex and a face",
    [IsPolygonalComplex, IsPosInt],
    function(complex, face)
        if not face in Faces(complex) then
            Error(Concatenation("RemoveFace: The given face ", face, 
                " is not a face of the given complex: ", 
                Faces(complex), ".") );
        fi;
        return RemoveFaceNC(complex, face);
    end
);
InstallMethod( RemoveFaceNC, "for a polygonal complex and a face",
    [IsPolygonalComplex, IsPosInt],
    function(complex, face)
        return RemoveFaces(complex,[face]);
    end
);


##
##      End of face removal
##
#######################################


#######################################
##
##      Disjoint Union
##

InstallOtherMethod(DisjointUnion, "for two polygonal complexes",
    [IsPolygonalComplex, IsPolygonalComplex],
    function(complex1, complex2)
        return DisjointUnion(complex1, complex2, 0);
    end
);
InstallMethod(DisjointUnion, "for two polygonal complexes and an integer",
    [IsPolygonalComplex, IsPolygonalComplex, IsInt],
    function(complex1, complex2, shift)
        local realShift, newVerticesOfEdges, newFacesOfEdges, obj, e;

        if IsEmpty( Intersection(Vertices(complex1), Vertices(complex2)) ) and
            IsEmpty( Intersection(Edges(complex1), Edges(complex2)) ) and
            IsEmpty( Intersection(Faces(complex1), Faces(complex2)) ) then
                realShift := 0;
        else
            realShift := Maximum( Concatenation( 
                Vertices(complex1), Edges(complex1), Faces(complex1) ) );
        fi;

        if shift > realShift then
            realShift := shift;
        fi;

        newVerticesOfEdges := ShallowCopy( VerticesOfEdges(complex1) );
        newFacesOfEdges := ShallowCopy( FacesOfEdges(complex1) );
        for e in Edges(complex2) do
            newVerticesOfEdges[e + realShift] := 
                List( VerticesOfEdges(complex2)[e], v -> v + realShift );
            newFacesOfEdges[e + realShift] := 
                List( FacesOfEdges(complex2)[e], f -> f + realShift );
        od;

        obj := Objectify( PolygonalComplexType, rec() );
        SetVerticesOfEdges(obj, newVerticesOfEdges);
        SetFacesOfEdges(obj, newFacesOfEdges);

        return [obj, realShift];
    end
);


##
##      End of disjoint union
##
#######################################


#######################################
##
##      Joining methods
##


## Vertices
InstallMethod( JoinVertices, "for two polygonal complexes and two vertices",
    [IsPolygonalComplex, IsPosInt, IsPolygonalComplex, IsPosInt],
    function(complex1, v1, complex2, v2)
        if not v1 in Vertices(complex1) then
            Error(Concatenation("JoinVertices: The first vertex ", v1, 
                " is not one of the vertices in the first polygonal complex: ", 
                Vertices(complex1), "."));
        fi;
        if not v2 in Vertices(complex2) then
            Error(Concatenation("JoinVertices: The second vertex ", v2, 
                " is not one of the vertices in the second polygonal complex: ", 
                Vertices(complex2), "."));
        fi;
        return JoinVerticesNC(complex1,v1,complex2,v2);
    end
);
InstallMethod( JoinVerticesNC, "for two polygonal complexes and two vertices",
    [IsPolygonalComplex, IsPosInt, IsPolygonalComplex, IsPosInt],
    function(complex1, v1, complex2, v2)
        local disjoint, join;

        disjoint := DisjointUnion(complex1, complex2);
        join := JoinVerticesNC( disjoint[1], v1, v2+disjoint[2] );
        if join = fail then
            return fail;
        fi;
        Add(join, disjoint[2]);
        return join;
    end
);

InstallOtherMethod( JoinVertices, 
    "for a polygonal complex and a list of two vertices",
    [IsPolygonalComplex, IsList],
    function(complex, vertList)
        local vertSet, label;

        vertSet := Set(vertList);
        if Size(vertSet) = 1 then
            label := vertSet[1];
        else
            label := Maximum(Vertices(complex)) + 1;
        fi;
        return JoinVertices(complex, vertSet, label);
    end
);
InstallOtherMethod( JoinVerticesNC,
    "for a polygonal complex and a list of two vertices",
    [IsPolygonalComplex, IsList],
    function(complex, vertList)
        local vertSet, label;

        vertSet := Set(vertList);
        if Size(vertSet) = 1 then
            label := vertSet[1];
        else
            label := Maximum(Vertices(complex)) + 1;
        fi;
        return JoinVerticesNC(complex, vertSet, label);
    end
);

InstallMethod( JoinVertices, 
    "for a polygonal complex, a list of two vertices and a new vertex label",
    [IsPolygonalComplex, IsList, IsPosInt],
    function(complex, vertList, newVertexLabel)
        local vertSet;

        vertSet := Set(vertList);
        if Size(vertSet) > 2 then
            Error(Concatenation("JoinVertices: Given vertex list ", vertList, 
                " contains more than two different elements."));
        fi;
        if not IsSubset(Vertices(complex), vertSet) then
            Error(Concatenation("JoinVertices: Given vertex list ", vertList,
                " is not a subset of the vertices of the given complex: ",
                Vertices(complex), "."));
        fi;
        if not newVertexLabel in vertSet and newVertexLabel in Vertices(complex) then
            Error(Concatenation("JoinVertices: Given new vertex label ", 
                newVertexLabel, " conflicts with existing vertices: ", 
                Vertices(complex), "."));
        fi;

        if Size(vertSet) = 2 then
            return JoinVerticesNC(complex, vertSet[1], vertSet[2], newVertexLabel);
        else
            return JoinVerticesNC(complex, vertSet[1], vertSet[1], newVertexLabel);
        fi;
    end
);
InstallMethod( JoinVerticesNC,
    "for a polygonal complex, a list of two vertices and a new vertex label",
    [IsPolygonalComplex, IsList, IsPosInt],
    function(complex, vertList, newVertexLabel)
        local vertSet;

        vertSet := Set(vertList);
        if Size(vertSet) = 2 then
            return JoinVerticesNC(complex, vertSet[1], vertSet[2], newVertexLabel);
        else
            return JoinVerticesNC(complex, vertSet[1], vertSet[1], newVertexLabel);
        fi;
    end
);

InstallOtherMethod( JoinVertices,
    "for a polygonal complex and two vertices",
    [IsPolygonalComplex, IsPosInt, IsPosInt],
    function(complex, v1, v2)
        local label;

        if v1 = v2 then
            label := v1;
        else
            label := Maximum(Vertices(complex))+1;
        fi;
        return JoinVertices(complex, v1, v2, label);
    end
);
InstallOtherMethod( JoinVerticesNC,
    "for a polygonal complex and two vertices",
    [IsPolygonalComplex, IsPosInt, IsPosInt],
    function(complex, v1, v2)
        local label;

        if v1 = v2 then
            label := v1;
        else
            label := Maximum(Vertices(complex))+1;
        fi;
        return JoinVerticesNC(complex, v1, v2, label);
    end
);

InstallMethod( JoinVertices,
    "for a polygonal complex, two vertices and a new vertex label",
    [IsPolygonalComplex, IsPosInt, IsPosInt, IsPosInt],
    function(complex, v1, v2, newVertexLabel)
        __SIMPLICIAL_CheckVertex(complex, v1, "JoinVertices");
        __SIMPLICIAL_CheckVertex(complex, v2, "JoinVertices");
        if newVertexLabel <> v1 and newVertexLabel <> v2 and newVertexLabel in Vertices(complex) then
            Error(Concatenation("JoinVertices: Given new vertex label ", 
                newVertexLabel, " conflicts with existing vertices: ", 
                Vertices(complex), "."));
        fi;

        return JoinVerticesNC(complex, v1, v2, newVertexLabel);
    end
);
InstallMethod( JoinVerticesNC,
    "for a polygonal complex, two vertices and a new vertex label",
    [IsPolygonalComplex, IsPosInt, IsPosInt, IsPosInt],
    function(complex, v1, v2, newVertexLabel)
        local newEdgesOfVertices, newEdges, obj;

        if v1 = v2 and v1 = newVertexLabel then
            return [complex, newVertexLabel];
        fi;

        if v1 <> v2 and ForAny( VerticesOfFaces(complex), verts -> IsSubset(verts,[v1,v2]) ) then
            return fail;
        fi;

        newEdgesOfVertices := ShallowCopy(EdgesOfVertices(complex));
        newEdges := Union( newEdgesOfVertices[v1], newEdgesOfVertices[v2] );
        Unbind(newEdgesOfVertices[v1]);
        Unbind(newEdgesOfVertices[v2]);
        newEdgesOfVertices[newVertexLabel] := newEdges;

        obj := Objectify(PolygonalComplexType, rec());
        SetEdgesOfVertices(obj, newEdgesOfVertices);
        SetFacesOfEdges(obj, FacesOfEdges(complex));

        return [obj, newVertexLabel];
    end
);



## Edges
InstallOtherMethod( JoinEdges, 
    "for a polygonal complex and a list of two edges",
    [IsPolygonalComplex, IsList],
    function(complex, edgeList)
        return JoinEdges(complex, edgeList, Maximum(Edges(complex))+1);
    end
);
InstallOtherMethod( JoinEdgesNC, 
    "for a polygonal complex and a list of two edges",
    [IsPolygonalComplex, IsList],
    function(complex, edgeList)
        return JoinEdgesNC(complex, edgeList, Maximum(Edges(complex))+1);
    end
);
InstallMethod( JoinEdges,
    "for a polygonal complex, a list of two edges and a new edge label",
    [IsPolygonalComplex, IsList, IsPosInt],
    function(complex, edgeList, newEdgeLabel)
         local edgeSet;

        edgeSet := Set(edgeList);
        if Size(edgeSet) <> 2 then
            Error(Concatenation("JoinEdges: Given edge list ", edgeList, 
                " contains more than two different elements."));
        fi;
        if not IsSubset(Edges(complex), edgeSet) then
            Error(Concatenation("JoinEdges: Given edge list ", edgeList,
                " is not a subset of the edges of the given complex: ",
                Edges(complex), "."));
        fi;
        if not newEdgeLabel in edgeSet and newEdgeLabel in Edges(complex) then
            Error(Concatenation("JoinEdges: Given new edge label ", 
                newEdgeLabel, " conflicts with existing edges: ", 
                Edges(complex), "."));
        fi;

        return JoinEdges(complex, edgeSet[1], edgeSet[2], newEdgeLabel);
    end
);
InstallMethod( JoinEdgesNC,
    "for a polygonal complex, a list of two edges and a new edge label",
    [IsPolygonalComplex, IsList, IsPosInt],
    function(complex, edgeList, newEdgeLabel)
        local edgeSet;

        edgeSet := Set(edgeList);
        return JoinEdgesNC(complex, edgeSet[1], edgeSet[2], newEdgeLabel);
    end
);

InstallOtherMethod( JoinEdges, "for a polygonal complex and two edges",
    [IsPolygonalComplex, IsPosInt, IsPosInt],
    function(complex, e1, e2)
        return JoinEdges(complex, e1, e2, Maximum(Edges(complex))+1);
    end
);
InstallOtherMethod( JoinEdgesNC, "for a polygonal complex and two edges",
    [IsPolygonalComplex, IsPosInt, IsPosInt],
    function(complex, e1, e2)
        return JoinEdgesNC(complex, e1, e2, Maximum(Edges(complex))+1);
    end
);

InstallMethod( JoinEdges, 
    "for a polygonal complex, two edges and a new edge label",
    [IsPolygonalComplex, IsPosInt, IsPosInt, IsPosInt],
    function(complex, e1, e2, newEdgeLabel)
        __SIMPLICIAL_CheckEdge(complex, e1, "JoinEdges");
        __SIMPLICIAL_CheckEdge(complex, e2, "JoinEdges");
        if e1 = e2 then
            Error(Concatenation("JoinEdges: Given edges are identical: ", e1, "."));
        fi;
        if newEdgeLabel <> e1 and newEdgeLabel <> e2 and newEdgeLabel in Edges(complex) then
            Error(Concatenation("JoinEdges: Given new edge label ", 
                newEdgeLabel, " conflicts with existing edges: ", 
                Edges(complex), "."));
        fi;
        if VerticesOfEdges(complex)[e1] <> VerticesOfEdges(complex)[e2] then
            Error(Concatenation(
                "JoinEdges: The two given edges are incident to different vertices, namely ",
                VerticesOfEdges(complex)[e1], " and ",
                VerticesOfEdges(complex)[e2], "."));
        fi;

        return JoinEdgesNC(complex, e1, e2, newEdgeLabel);
    end
);
InstallMethod( JoinEdgesNC,
    "for a polygonal complex, two edges and a new edge label",
    [IsPolygonalComplex, IsPosInt, IsPosInt, IsPosInt],
    function(complex, e1, e2, newEdgeLabel)
        local obj, newVerticesOfEdges, newFacesOfEdges, faces, verts;

        newVerticesOfEdges := ShallowCopy( VerticesOfEdges(complex) );
        newFacesOfEdges := ShallowCopy( FacesOfEdges(complex) );

        verts := newVerticesOfEdges[e1];
        Unbind(newVerticesOfEdges[e1]);
        Unbind(newVerticesOfEdges[e2]);
        newVerticesOfEdges[newEdgeLabel] := verts;

        faces := Union(newFacesOfEdges[e1], newFacesOfEdges[e2]);
        Unbind(newFacesOfEdges[e1]);
        Unbind(newFacesOfEdges[e2]);
        newFacesOfEdges[newEdgeLabel] := faces;

        obj := Objectify( PolygonalComplexType, rec() );
        SetVerticesOfEdges(obj, newVerticesOfEdges);
        SetFacesOfEdges(obj, newFacesOfEdges);
        return [obj, newEdgeLabel];
    end
);




## VertexEdgePaths
## Section 1
InstallMethod( JoinVertexEdgePaths, 
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, 
        IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex1, vePath1, complex2, vePath2)
        if complex1 <> AssociatedPolygonalComplex(vePath1) then
            Error(Concatenation("JoinVertexEdgePaths: The first path ", 
                vePath1, " does not belong to the first polygonal complex."));
        fi;
        if complex2 <> AssociatedPolygonalComplex(vePath2) then
            Error(Concatenation("JoinVertexEdgePaths: The second path ", 
                vePath2, " does not belong to the first polygonal complex."));
        fi;

        if Size(VerticesAsList(vePath1)) <> Size(VerticesAsList(vePath2)) then
            Error(Concatenation("JoinVertexEdgePaths: The given paths ",
                vePath1, " and ", vePath2, " have different lengths."));
        fi;

        return JoinVertexEdgePathsNC(complex1, vePath1, complex2, vePath2);
    end
);
RedispatchOnCondition( JoinVertexEdgePaths, true, 
    [IsPolygonalComplex, IsVertexEdgePath, IsPolygonalComplex, IsVertexEdgePath],
    [,IsDuplicateFree,,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePaths,
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, IsPolygonalComplex, IsList],
    function(complex1, vePath1, complex2, pathAsList2)
        return JoinVertexEdgePaths(complex1, vePath1, complex2, VertexEdgePath(complex2, pathAsList2));
    end
);
RedispatchOnCondition( JoinVertexEdgePaths, true,
    [IsPolygonalComplex, IsVertexEdgePath, IsPolygonalComplex, IsList],
    [,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePaths,
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsList, IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex1, pathAsList1, complex2, vePath2)
        return JoinVertexEdgePaths(complex1, VertexEdgePath(complex1, pathAsList1), complex2, vePath2);
    end
);
RedispatchOnCondition( JoinVertexEdgePaths, true,
    [IsPolygonalComplex, IsList, IsPolygonalComplex, IsVertexEdgePath],
    [,,,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePaths,
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex,IsList,IsPolygonalComplex,IsList],
    function(complex1, pathAsList1, complex2, pathAsList2)
        return JoinVertexEdgePaths(complex1, VertexEdgePath(complex1, pathAsList1), complex2, VertexEdgePath(complex2, pathAsList2));
    end
);

## Section 2
InstallMethod( JoinVertexEdgePathsNC, 
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, 
        IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex1, vePath1, complex2, vePath2)
        local disjoint, join;

        disjoint := DisjointUnion(complex1, complex2);
        join := JoinVertexEdgePathsNC(disjoint[1], vePath1, 
            VertexEdgePath(disjoint[1], List(PathAsList(vePath2), x -> x+disjoint[2]) ) );
        if join = fail then
            return fail;
        fi;

        Add(join, disjoint[2]);
        return join;
    end
);
RedispatchOnCondition( JoinVertexEdgePathsNC, true, 
    [IsPolygonalComplex, IsVertexEdgePath, IsPolygonalComplex, IsVertexEdgePath],
    [,IsDuplicateFree,,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePathsNC,
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, IsPolygonalComplex, IsList],
    function(complex1, vePath1, complex2, pathAsList2)
        return JoinVertexEdgePathsNC(complex1, vePath1, complex2, VertexEdgePath(complex2, pathAsList2));
    end
);
RedispatchOnCondition( JoinVertexEdgePathsNC, true,
    [IsPolygonalComplex, IsVertexEdgePath, IsPolygonalComplex, IsList],
    [,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePathsNC,
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsList, IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree],
    function(complex1, pathAsList1, complex2, vePath2)
        return JoinVertexEdgePathsNC(complex1, VertexEdgePath(complex1, pathAsList1), complex2, vePath2);
    end
);
RedispatchOnCondition( JoinVertexEdgePathsNC, true,
    [IsPolygonalComplex, IsList, IsPolygonalComplex, IsVertexEdgePath],
    [,,,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePathsNC,
    "for two polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex,IsList,IsPolygonalComplex,IsList],
    function(complex1, pathAsList1, complex2, pathAsList2)
        return JoinVertexEdgePathsNC(complex1, VertexEdgePath(complex1, pathAsList1), complex2, VertexEdgePath(complex2, pathAsList2));
    end
);

## Section 3
InstallMethod( JoinVertexEdgePaths, 
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, 
        IsVertexEdgePath and IsDuplicateFree],
    function(complex, vePath1, vePath2)
        if complex <> AssociatedPolygonalComplex(vePath1) then
            Error(Concatenation("JoinVertexEdgePaths: The first path ", 
                vePath1, " does not belong to the polygonal complex."));
        fi;
        if complex <> AssociatedPolygonalComplex(vePath2) then
            Error(Concatenation("JoinVertexEdgePaths: The second path ", 
                vePath2, " does not belong to the polygonal complex."));
        fi;

        if Size(VerticesAsList(vePath1)) <> Size(VerticesAsList(vePath2)) then
            Error(Concatenation("JoinVertexEdgePaths: The given paths ",
                vePath1, " and ", vePath2, " have different lengths."));
        fi;

        return JoinVertexEdgePathsNC(complex, vePath1, vePath2);
    end
);
RedispatchOnCondition( JoinVertexEdgePaths, true, 
    [IsPolygonalComplex, IsVertexEdgePath, IsVertexEdgePath],
    [,IsDuplicateFree,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePaths,
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, IsList],
    function(complex, vePath1, pathAsList2)
        return JoinVertexEdgePaths(complex, vePath1, VertexEdgePath(complex, pathAsList2));
    end
);
RedispatchOnCondition( JoinVertexEdgePaths, true,
    [IsPolygonalComplex, IsVertexEdgePath, IsList],
    [,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePaths,
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsList, IsVertexEdgePath and IsDuplicateFree],
    function(complex, pathAsList1, vePath2)
        return JoinVertexEdgePaths(complex, VertexEdgePath(complex, pathAsList1), vePath2);
    end
);
RedispatchOnCondition( JoinVertexEdgePaths, true,
    [IsPolygonalComplex, IsList, IsVertexEdgePath],
    [,,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePaths,
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex,IsList,IsList],
    function(complex, pathAsList1, pathAsList2)
        return JoinVertexEdgePaths(complex, VertexEdgePath(complex, pathAsList1), VertexEdgePath(complex, pathAsList2));
    end
);

## Section 4
InstallMethod( JoinVertexEdgePathsNC, 
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, 
        IsVertexEdgePath and IsDuplicateFree],
    function(complex, vePath1, vePath2)
        local swapComplex, labelList, i, join, v1, v2, size;

        swapComplex := complex;
        labelList := [];

        # Identify vertices
        for i in [1..Size(VerticesAsList(vePath1))-1] do;
            join := JoinVerticesNC( swapComplex, VerticesAsList(vePath1)[i], VerticesAsList(vePath2)[i] );
            if join = fail then
                return fail;
            fi;
            labelList[2*i-1] := join[2];
            swapComplex := join[1];
        od;
        # The last step has to be handled differently if the paths are closed
        size := Size(VerticesAsList(vePath1));
        if IsClosedPath(vePath1) then
            v1 := labelList[1];
        else
            v1 := VerticesAsList(vePath1)[size];
        fi;
        if IsClosedPath(vePath2) then
            v2 := labelList[1];
        else
            v2 := VerticesAsList(vePath2)[size];
        fi;
        join := JoinVerticesNC( swapComplex, v1, v2 );
        if join = fail then
            return fail;
        fi;
        labelList[2*size-1] := join[2];
        swapComplex := join[1];


        # Identify edges
        for i in [1..Size(EdgesAsList(vePath1))] do
            join := JoinEdgesNC( swapComplex, EdgesAsList(vePath1)[i], EdgesAsList(vePath2)[i] );
            labelList[2*i] := join[2];
            swapComplex := join[1];
        od;

        return [swapComplex, VertexEdgePath(swapComplex, labelList)];
    end
);
RedispatchOnCondition( JoinVertexEdgePathsNC, true, 
    [IsPolygonalComplex, IsVertexEdgePath, IsVertexEdgePath],
    [,IsDuplicateFree,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePathsNC,
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsVertexEdgePath and IsDuplicateFree, IsList],
    function(complex, vePath1, pathAsList2)
        return JoinVertexEdgePathsNC(complex, vePath1, VertexEdgePath(complex, pathAsList2));
    end
);
RedispatchOnCondition( JoinVertexEdgePathsNC, true,
    [IsPolygonalComplex, IsVertexEdgePath, IsList],
    [,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePathsNC,
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex, IsList, IsVertexEdgePath and IsDuplicateFree],
    function(complex, pathAsList1, vePath2)
        return JoinVertexEdgePathsNC(complex, VertexEdgePath(complex, pathAsList1), vePath2);
    end
);
RedispatchOnCondition( JoinVertexEdgePathsNC, true,
    [IsPolygonalComplex, IsList, IsVertexEdgePath],
    [,,IsDuplicateFree], 0);

InstallOtherMethod(JoinVertexEdgePathsNC,
    "for a polygonal complexes and two duplicate-free vertex-edge-paths",
    [IsPolygonalComplex,IsList,IsList],
    function(complex, pathAsList1, pathAsList2)
        return JoinVertexEdgePathsNC(complex, VertexEdgePath(complex, pathAsList1), VertexEdgePath(complex, pathAsList2));
    end
);


## Boundaries
InstallMethod(JoinBoundaries,
    "for two polygonal surfaces and two 2-flags",
    [IsPolygonalSurface, IsList, IsPolygonalSurface, IsList],
    function(surface1, flag1, surface2, flag2)
        local disjoint, join;

        disjoint := DisjointUnion(surface1, surface2);
        join := JoinBoundaries( disjoint[1], flag1, List(flag2, x -> x + disjoint[2]) );
        if join = fail then
            return fail;
        fi;
        Add(join, disjoint[2]);
        return join;
    end
);
RedispatchOnCondition( JoinBoundaries, true, [IsPolygonalComplex, IsList, IsPolygonalComplex, IsList], [IsPolygonalSurface,,IsPolygonalSurface], 0 );
InstallMethod(JoinBoundaries,
    "for a polygonal surface and two 2-flags",
    [IsPolygonalSurface, IsList, IsList],
    function(surface, flag1, flag2)
        local perims, perim1, perim2, bound1, bound2, Reorient;

        if Size(flag1) < 2 then
            Error(Concatenation("JoinBoundaries: First 2-flag should contain two elements, but actually has ", Size(flag1),"."));
        fi;
        if Size(flag2) < 2 then
            Error(Concatenation("JoinBoundaries: Second 2-flag should contain two elements, but actually has ", Size(flag2),"."));
        fi;
        if not IsBoundaryVertex(surface, flag1[1]) then
            Error(Concatenation("JoinBoundaries: Vertex ", flag1[1], " of first flag is not a boundary vertex."));
        fi;
        if not IsBoundaryVertex(surface, flag2[1]) then
            Error(Concatenation("JoinBoundaries: Vertex ", flag2[1], " of second flag is not a boundary vertex."));
        fi;
        if not IsBoundaryEdge(surface, flag1[2]) then
            Error(Concatenation("JoinBoundaries: Edge ", flag1[2], " of first flag is not a boundary edge."));
        fi;
        if not IsBoundaryEdge(surface, flag2[2]) then
            Error(Concatenation("JoinBoundaries: Edge ", flag2[2], " of second flag is not a boundary edge."));
        fi;
        if not flag1[1] in VerticesOfEdges(surface)[flag1[2]] then
            Error(Concatenation("JoinBoundaries: First list ", flag1, " should be a flag of a vertex and an edge."));
        fi;
        if not flag2[1] in VerticesOfEdges(surface)[flag2[2]] then
            Error(Concatenation("JoinBoundaries: Second list ", flag2, " should be a flag of a vertex and an edge."));
        fi;

        perims := PerimeterOfHoles(surface);
        # Each edge can be in only one boundary path
        #TODO could this become another VertexEdgePath-Constructor?
        perim1 := Filtered(perims, p -> flag1[2] in EdgesAsList(p));
        perim2 := Filtered(perims, p -> flag2[2] in EdgesAsList(p));
        Assert(0, Size(perim1) = 1);
        Assert(0, Size(perim2) = 1);
        perim1 := perim1[1];
        perim2 := perim2[1];

        # We have to reorient the paths correctly
        # TODO this could be a separate method
        Reorient := function( path, vertex, edge )
            local vPos, ePos, i;

            if path[1] = vertex and path[2] = edge then
                return path;
            fi;
            if path[Size(path)] = vertex and path[Size(path)-1] = edge then
                return Reversed(path);
            fi;

            vPos := 0;
            for i in [3,5..Size(path)-2] do
                if path[i] = vertex then
                    vPos := i;
                fi;
            od;
            Assert(0, vPos > 0);

            ePos := 0;
            for i in [2,4..Size(path)-1] do
                if path[i] = edge then
                    ePos := i;
                fi;
            od;
            Assert(0, ePos > 0);

            if vPos + 1 = ePos then
                # right direction
                return Concatenation( path{[vPos..Size(path)-1]}, path{[1..vPos]} );
            elif ePos + 1 = vPos then
                # wrong direction
                return Reversed( Concatenation( path{[vPos..Size(path)]}, path{[1..vPos]} ) );
            fi;
            Error("JoinBoundaries: Internal Error");
        end;

        bound1 := VertexEdgePath( surface, Reorient( PathAsList(perim1), flag1[1], flag1[2] ) );
        bound2 := VertexEdgePath( surface, Reorient( PathAsList(perim2), flag2[1], flag2[2] ) );
        return JoinVertexEdgePathsNC(surface, bound1, bound2);
    end
);
RedispatchOnCondition( JoinBoundaries, true, [IsPolygonalComplex, IsList, IsList], [IsPolygonalSurface], 0 );



##
##      End of joining
##
#######################################
