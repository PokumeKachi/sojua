use bevy::prelude::*;

pub struct GamePlugin;

impl Plugin for GamePlugin {
    fn build(&self, app: &mut App) {
        println!("sup");
        app.add_systems(Startup, (spawn_floor, spawn_camera));
        app.add_systems(Update, move_camera);
        // .add_systems(Update, player_movement);
    }
}

fn main() {
    App::new().add_plugins((DefaultPlugins, GamePlugin)).run();
}

fn move_camera(
    time: Res<Time>,
    keys: Res<ButtonInput<KeyCode>>,
    mut q: Query<&mut Transform, With<Camera3d>>,
) {
    let mut t = q.single_mut().unwrap();
    // let speed = 5.0 * time.delta_secs();

    let time = time.elapsed_secs() * 5.0;

    t.translation.z = time.sin() + 5.0;
    // if keys.pressed(KeyCode::KeyW) {
    //     t.translation.z -= speed;
    // }
    // if keys.pressed(KeyCode::KeyS) {
    //     t.translation.z += speed;
    // }
}

fn spawn_camera(mut commands: Commands) {
    commands.spawn((
        Camera3d::default(),
        Transform::from_xyz(-2.0, 2.5, 5.0).looking_at(Vec3::ZERO, Vec3::Y),
        GlobalTransform::default(),
    ));
}

fn spawn_floor(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    // circular base
    commands.spawn((
        Mesh3d(meshes.add(Circle::new(4.0))),
        MeshMaterial3d(materials.add(Color::WHITE)),
        Transform::from_rotation(Quat::from_rotation_x(-std::f32::consts::FRAC_PI_2)),
    ));
    // cube
    commands.spawn((
        Mesh3d(meshes.add(Cuboid::new(1.0, 1.0, 1.0))),
        MeshMaterial3d(materials.add(Color::srgb_u8(124, 144, 255))),
        Transform::from_xyz(0.0, 0.5, 0.0),
    ));
    // light
    commands.spawn((
        PointLight {
            shadows_enabled: true,
            ..default()
        },
        Transform::from_xyz(4.0, 8.0, 4.0),
    ));
}
