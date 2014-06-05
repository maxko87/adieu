@People = new Meteor.Collection("people")

if Meteor.isServer
  persons = Assets.getText('students.json')
  # persons = [{"name": "Max", "athena": "mkolysh"}, {"name": "Maximax", "athena": "mkolysh2"}, {"name": "Doug", "athena": "dougfeig"}, {"name": "Ben", "athena": "bfrank"}]

  if People.find().count() == 0
    for person in persons
      People.insert({"name": person.name, "athena": person.athena, "comments": []})

  Meteor.publish "people", ->
    People.find()

if Meteor.isClient

  Deps.autorun ->
    Meteor.subscribe("people")

  find_person = (person) ->
    if person
      Session.set("person_id", person._id)
    else
      delete Session.keys["person"]

  Template.content.person = ->
    id = Session.get("person_id")
    People.findOne(id)

  Template.search_bar.autocomplete_settings = ->
    position: "bottom"
    limit: 5
    rules: [
      collection: People
      field: "name"
      template: Template.autocomplete_pill
      callback: find_person
    ]

  Template.search.events
    "keypress #search-box": (evt) ->
      if evt.which == 13
        name = $(evt.target).val()
        person = People.findOne({"name": name})
        find_person(person)

  Template.post_box.events
    #keypress #post-box-input, 
    "click #post-box-submit": (evt) ->
      content = $("#post-box-input").val()
      id = Session.get("person_id")
      comment = {content: content}
      People.update({_id: id}, {$push: {comments: comment}})
      $("#post-box-input").val("") 
      # TODO: disappear post-box
      return false



