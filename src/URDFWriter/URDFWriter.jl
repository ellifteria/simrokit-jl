module URDFWriter

# include XML writing tool

include("../../deps/juliaxmlwriter/src/XMLWriter.jl")
using .XMLWriter

# Internal types

Optional{T} = Union{T, Nothing}

# URDFWriter: URDFOrigin: exported functions

export urdfwriter_urdforigin_create

function urdfwriter_urdforigin_create(
    xyz::Optional{Vector{Float64}}=nothing,
    rpy::Optional{Vector{Float64}}=nothing
  )::XmlNode

  xml_origin = xmlwriter_xmlnode_create("origin")

  if !isnothing(xyz)
    xmlwriter_xmlnode_add_tag!(
      xml_origin,
      "xyz",
      "\"$(xyz[1]) $(xyz[2]) $(xyz[3])\""
    )
  end

  if !isnothing(rpy)
    xmlwriter_xmlnode_add_tag!(
      xml_origin,
      "rpy",
      "\"$(rpy[1]) $(rpy[2]) $(rpy[3])\""
    )
  end

  return xml_origin

end

# URDFWriter: URDFGeom: exported types

export AbstractURDFGeom,
       URDFGeomBox,
       URDFGeomCylinder,
       URDFGeomSphere,
       URDFGeomMesh

abstract type AbstractURDFGeom end

struct URDFGeomBox <: AbstractURDFGeom
  size_x::Float64
  size_y::Float64
  size_z::Float64
end

struct URDFGeomCylinder <: AbstractURDFGeom
  radius::Float64
  length::Float64
end

struct URDFGeomSphere <: AbstractURDFGeom
  radius::Float64
end

struct URDFGeomMesh <: AbstractURDFGeom
  file_path::String
  scale_x::Float64
  scale_y::Float64
  scale_z::Float64
end

# URDFWriter: URDFGeom: exported functions

export urdfwriter_urdfgeom_create

function urdfwriter_urdfgeom_create(
    geometry::AbstractURDFGeom
  )::XmlNode

  xml_geom = xmlwriter_xmlnode_create("geometry")

  geom_type::String = ""

  if isa(geometry, URDFGeomBox)
    geom_type = "box"
  elseif isa(geometry, URDFGeomCylinder)
    geom_type = "cylinder"
  elseif isa(geometry, URDFGeomSphere)
    geom_type = "sphere"
  elseif isa(geometry, URDFGeomMesh)
    geom_type = "mesh"
  end

  xml_geom_spec = xmlwriter_xmlnode_create(geom_type)

  if isa(geometry, URDFGeomBox)
    xmlwriter_xmlnode_add_tag!(
      xml_geom_spec,
      "size",
      "\"$(geometry.size_x) $(geometry.size_y) $(geometry.size_z)\""
    )
  elseif isa(geometry, URDFGeomCylinder)
    xmlwriter_xmlnode_add_tag!(
      xml_geom_spec,
      "radius",
      "\"$(geometry.radius)\""
    )
    xmlwriter_xmlnode_add_tag!(
      xml_geom_spec,
      "length",
      "\"$(geometry.length)"
    )
  elseif isa(geometry, URDFGeomSphere)
    xmlwriter_xmlnode_add_tag!(
      xml_geom_spec,
      "radius",
      "\"$(geometry.radius)\""
    )
  elseif isa(geometry, URDFGeomMesh)
    xmlwriter_xmlnode_add_tag!(
      xml_geom_spec,
      "filename",
      "\"$(geometry.file_path)\""
    )
    xmlwriter_xmlnode_add_tag!(
      xml_geom_spec,
      "scale",
      "\"$(geometry.scale_x) $(geometry.scale_y) $(geometry.scale.z)\""
    )
  end
  xmlwriter_xmlnode_add_child!(xml_geom, xml_geom_spec)

  return xml_geom
  
end

# URDFWriter: URDFVisualMaterial: exported functions

export urdfwriter_urdfmaterial_create

function urdfwriter_urdfmaterial_create(
    color::Optional{Vector{Float64}}=nothing,
    texture_file_path::Optional{String}=nothing
  )::XmlNode

  xml_material = xmlwriter_xmlnode_create("material")

  if !isnothing(color)
    xmlwriter_xmlnode_add_child!(
      xml_material,
      "color",
      Dict("rgba" => "\"$(color[1]) $(color[2]) $(color[3])\"")
    )
  end

  if !isnothing(texture_file_path)
    xmlwriter_xmlnode_add_tag!(
      xml_material,
      "texture",
      "\"$(texture_file_path)\""
    )
  end

  return xml_material

end

# URDFWriter: URDFInertia: exported functions

export urdfwriter_urdfinterial_create

function urdfwriter_urdfinterial_create(
  mass::Optional{Float64}=nothing,
  inertia::Optional{Vector{Float64}}=nothing,
  origin::Optional{XmlNode}=nothing
)
  xml_inertial = xmlwriter_xmlnode_create("inertial")

  if !isnothing(mass)
    xmlwriter_xmlnode_add_child!(
      xml_inertial,
      "mass",
      Dict("value" => "\"$(mass)\"")
    )
  end

  if !isnothing(inertia)
    xmlwriter_xmlnode_add_child!(
      xml_inertial,
      "inertia",
      Dict(
        "ixx" => "\"$(inertia[1])\"",
        "ixy" => "\"$(inertia[2])\"",
        "ixz" => "\"$(inertia[3])\"",
        "iyy" => "\"$(inertia[4])\"",
        "iyz" => "\"$(inertia[5])\"",
        "izz" => "\"$(inertia[6])\"",
      )
    )
  end

  if !isnothing(origin)
    xmlwriter_xmlnode_add_child!(xml_inertial, origin)
  end

  return xml_inertial
end

# URDFWriter: URDFLink: exported functions

export urdfwriter_urdflink_create,
       urdfwriter_urdflink_create_visual

function urdfwriter_urdflink_create_visual(
    geometry::XmlNode,
    name::Optional{String}=nothing,
    origin::Optional{XmlNode}=nothing,
    material::Optional{XmlNode}=nothing
  )::XmlNode

  xml_visual = xmlwriter_xmlnode_create("visual")

  if !isnothing(name)
    xmlwriter_xmlnode_add_tag!(xml_visual, "name", "\"$(name)\"")
  end

  if !isnothing(origin)
    xmlwriter_xmlnode_add_child!(xml_visual, origin)
  end

  if !isnothing(geometry)
    xmlwriter_xmlnode_add_child!(xml_visual, geometry)
  end

  if !isnothing(material)
    xmlwriter_xmlnode_add_child!(xml_visual, material)
  end

  return xml_visual

end

function urdfwriter_urdflink_create(
    name::String,
    visual::Optional{XmlNode}=nothing
  )::XmlNode

  link = xmlwriter_xmlnode_create("link", Dict("name" => "\"$(name)\""))

  if !isnothing(visual)
    xmlwriter_xmlnode_add_child!(link, visual)
  end

  return link

end

# URDFWriter: URDFJoint: exported functions

export urdfwriter_urdfjoint_create

function urdfwriter_urdfjoint_create(name::String)::XmlNode

  return xmlwriter_xmlnode_create(name)

end


# URDFWriter: URDFFile: exported functions 

export urdfwriter_urdffile_create,
       urdfwriter_urdffile_write,
       urdfwriter_urdffile_add_link!,
       urdfwriter_urdffile_add_joint!

function urdfwriter_urdffile_create(name::String="robot")::XmlNode

  return xmlwriter_xmlnode_create("robot", Dict("name" => "\"$(name)\""))

end

function urdfwriter_urdffile_add_link!(
    urdf_doc::XmlNode,
    link::XmlNode
  )

  xmlwriter_xmlnode_add_child!(urdf_doc, link)

end

function urdfwriter_urdffile_add_joint!(
    urdf_doc::XmlNode,
    joint::XmlNode
  )

  xmlwriter_xmlnode_add_child!(urdf_doc, joint)

end

function urdfwriter_urdffile_write(
    file_path::String,
    urdf_doc::XmlNode
  )

  xmlwriter_xmlnode_write(file_path, urdf_doc)

end

end

