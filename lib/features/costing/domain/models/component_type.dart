/// Encodes HOW a component's cost is calculated.
///
/// Previously this was smuggled through the [capacity] field of
/// [CapacityBasedComponent] with different sentinel values depending on context.
/// Now it is an explicit, type-safe discriminant.
enum ComponentType {
  /// cost = quantity × unitPrice
  /// e.g. inverter, DCDB, earthing material
  quantityBased,

  /// cost = plantCapacity × unitPrice × quantity
  /// e.g. mounting structure, installation
  plantCapacityBased,

  /// cost = panelCapacity × unitPrice × quantity
  /// e.g. solar panel (panel Wp × price/Wp × number of panels)
  panelCapacityBased,
}
